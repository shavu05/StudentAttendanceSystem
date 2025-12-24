package com.attendance.dao;

import com.attendance.model.Attendance;
import com.attendance.util.DatabaseConnection;

import java.sql.*;
import java.util.*;
import java.util.Date;

public class AttendanceDAO {
    
    // Mark attendance for a student
    public boolean markAttendance(Attendance attendance) throws SQLException {
        String sql = "INSERT INTO attendance (student_id, teacher_id, attendance_date, status, remarks) " +
                     "VALUES (?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE status = VALUES(status), remarks = VALUES(remarks)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, attendance.getStudentId());
            pstmt.setInt(2, attendance.getTeacherId());
            pstmt.setDate(3, attendance.getAttendanceDate());
            pstmt.setString(4, attendance.getStatus());
            pstmt.setString(5, attendance.getRemarks());
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    // Get today's attendance for a teacher
    public List<Attendance> getAttendanceByDate(String date, int teacherId) throws SQLException {
        List<Attendance> attendanceList = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name, u.roll_no, u.class " +
                     "FROM attendance a " +
                     "JOIN users u ON a.student_id = u.id " +
                     "WHERE a.attendance_date = ? AND a.teacher_id = ? " +
                     "ORDER BY u.roll_no";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, date);
            pstmt.setInt(2, teacherId);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Attendance attendance = extractAttendanceFromResultSet(rs);
                attendanceList.add(attendance);
            }
        }
        return attendanceList;
    }
    
    // Get detailed attendance with student info
    public List<Map<String, Object>> getAttendanceDetails(String date, int teacherId) throws SQLException {
        List<Map<String, Object>> details = new ArrayList<>();
        String sql = "SELECT u.id as student_id, u.roll_no, u.full_name, u.class, " +
                     "COALESCE(a.status, 'not_marked') as status, a.remarks, " +
                     "COALESCE(a.marked_at, NULL) as marked_at " +
                     "FROM users u " +
                     "LEFT JOIN attendance a ON u.id = a.student_id AND a.attendance_date = ? " +
                     "WHERE u.role = 'student' AND (u.class IN (SELECT class FROM users WHERE id = ?) OR ? = 0) " +
                     "ORDER BY u.roll_no";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, date);
            pstmt.setInt(2, teacherId);
            pstmt.setInt(3, teacherId);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("studentId", rs.getInt("student_id"));
                record.put("rollNo", rs.getString("roll_no"));
                record.put("fullName", rs.getString("full_name"));
                record.put("className", rs.getString("class"));
                record.put("status", rs.getString("status"));
                record.put("remarks", rs.getString("remarks"));
                record.put("markedAt", rs.getTimestamp("marked_at"));
                details.add(record);
            }
        }
        return details;
    }
    
    // Get student attendance statistics
    public Map<String, Object> getStudentAttendanceStats(int studentId) throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        
        // Yearly stats
        String yearlySql = "SELECT " +
                          "COUNT(*) as total_days, " +
                          "SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_days, " +
                          "ROUND((SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as percentage " +
                          "FROM attendance " +
                          "WHERE student_id = ? AND YEAR(attendance_date) = YEAR(CURDATE())";
        
        // Monthly stats
        String monthlySql = "SELECT " +
                           "COUNT(*) as total_days, " +
                           "SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present_days, " +
                           "ROUND((SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as percentage " +
                           "FROM attendance " +
                           "WHERE student_id = ? AND YEAR(attendance_date) = YEAR(CURDATE()) " +
                           "AND MONTH(attendance_date) = MONTH(CURDATE())";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement yearlyStmt = conn.prepareStatement(yearlySql);
             PreparedStatement monthlyStmt = conn.prepareStatement(monthlySql)) {
            
            yearlyStmt.setInt(1, studentId);
            monthlyStmt.setInt(1, studentId);
            
            ResultSet yearlyRs = yearlyStmt.executeQuery();
            if (yearlyRs.next()) {
                stats.put("yearlyTotal", yearlyRs.getInt("total_days"));
                stats.put("yearlyPresent", yearlyRs.getInt("present_days"));
                stats.put("yearlyPercentage", yearlyRs.getDouble("percentage"));
            }
            
            ResultSet monthlyRs = monthlyStmt.executeQuery();
            if (monthlyRs.next()) {
                stats.put("monthlyTotal", monthlyRs.getInt("total_days"));
                stats.put("monthlyPresent", monthlyRs.getInt("present_days"));
                stats.put("monthlyPercentage", monthlyRs.getDouble("percentage"));
            }
        }
        return stats;
    }
    
    // Get low attendance students (< threshold percentage)
    public List<Map<String, Object>> getLowAttendanceStudents(int teacherId, double threshold) throws SQLException {
        List<Map<String, Object>> students = new ArrayList<>();
        String sql = "SELECT u.id, u.roll_no, u.full_name, u.class, u.parent_phone, u.parent_email, " +
                     "COUNT(a.id) as total_days, " +
                     "SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_days, " +
                     "ROUND((SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) / COUNT(a.id)) * 100, 2) as attendance_percentage " +
                     "FROM users u " +
                     "LEFT JOIN attendance a ON u.id = a.student_id " +
                     "WHERE u.role = 'student' AND (u.class IN (SELECT class FROM users WHERE id = ?) OR ? = 0) " +
                     "GROUP BY u.id " +
                     "HAVING attendance_percentage < ? OR attendance_percentage IS NULL " +
                     "ORDER BY attendance_percentage ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacherId);
            pstmt.setInt(2, teacherId);
            pstmt.setDouble(3, threshold);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> student = new HashMap<>();
                student.put("id", rs.getInt("id"));
                student.put("rollNo", rs.getString("roll_no"));
                student.put("fullName", rs.getString("full_name"));
                student.put("className", rs.getString("class"));
                student.put("parentPhone", rs.getString("parent_phone"));
                student.put("parentEmail", rs.getString("parent_email"));
                student.put("totalDays", rs.getInt("total_days"));
                student.put("presentDays", rs.getInt("present_days"));
                student.put("attendancePercentage", rs.getDouble("attendance_percentage"));
                students.add(student);
            }
        }
        return students;
    }
    
    // Get monthly report data
    public List<Map<String, Object>> getMonthlyReport(int teacherId, String month, String year, String className) 
            throws SQLException {
        List<Map<String, Object>> report = new ArrayList<>();
        String sql = "SELECT u.id, u.roll_no, u.full_name, u.class, " +
                     "COUNT(a.id) as total_days, " +
                     "SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_days, " +
                     "SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_days, " +
                     "ROUND((SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) / COUNT(a.id)) * 100, 2) as attendance_percentage " +
                     "FROM users u " +
                     "LEFT JOIN attendance a ON u.id = a.student_id " +
                     "AND MONTH(a.attendance_date) = ? AND YEAR(a.attendance_date) = ? " +
                     "WHERE u.role = 'student' " +
                     "AND (? = 'all' OR u.class = ?) " +
                     "AND (u.class IN (SELECT class FROM users WHERE id = ?) OR ? = 0) " +
                     "GROUP BY u.id " +
                     "ORDER BY u.roll_no";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, month);
            pstmt.setString(2, year);
            pstmt.setString(3, className);
            pstmt.setString(4, className);
            pstmt.setInt(5, teacherId);
            pstmt.setInt(6, teacherId);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("id", rs.getInt("id"));
                record.put("rollNo", rs.getString("roll_no"));
                record.put("fullName", rs.getString("full_name"));
                record.put("className", rs.getString("class"));
                record.put("totalDays", rs.getInt("total_days"));
                record.put("presentDays", rs.getInt("present_days"));
                record.put("absentDays", rs.getInt("absent_days"));
                record.put("attendancePercentage", rs.getDouble("attendance_percentage"));
                report.add(record);
            }
        }
        return report;
    }
    
    // Get recent activity
    public List<Map<String, Object>> getRecentActivity(int teacherId, int limit) throws SQLException {
        List<Map<String, Object>> activity = new ArrayList<>();
        String sql = "SELECT DATE(a.attendance_date) as date, u.class, " +
                     "COUNT(*) as total_students, " +
                     "SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_count, " +
                     "SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_count, " +
                     "ROUND((SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as percentage " +
                     "FROM attendance a " +
                     "JOIN users u ON a.student_id = u.id " +
                     "WHERE a.teacher_id = ? " +
                     "GROUP BY DATE(a.attendance_date), u.class " +
                     "ORDER BY date DESC LIMIT ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacherId);
            pstmt.setInt(2, limit);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("date", rs.getDate("date"));
                record.put("className", rs.getString("class"));
                record.put("totalStudents", rs.getInt("total_students"));
                record.put("presentCount", rs.getInt("present_count"));
                record.put("absentCount", rs.getInt("absent_count"));
                record.put("percentage", rs.getDouble("percentage"));
                activity.add(record);
            }
        }
        return activity;
    }
    
    // Get monthly attendance data for charts
    public List<Map<String, Object>> getMonthlyAttendanceData(int teacherId) throws SQLException {
        List<Map<String, Object>> data = new ArrayList<>();
        String sql = "SELECT MONTHNAME(a.attendance_date) as month, " +
                     "COUNT(*) as total, " +
                     "SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present, " +
                     "SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent " +
                     "FROM attendance a " +
                     "WHERE a.teacher_id = ? AND YEAR(a.attendance_date) = YEAR(CURDATE()) " +
                     "GROUP BY MONTH(a.attendance_date) " +
                     "ORDER BY MONTH(a.attendance_date)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, teacherId);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> monthData = new HashMap<>();
                monthData.put("month", rs.getString("month"));
                monthData.put("total", rs.getInt("total"));
                monthData.put("present", rs.getInt("present"));
                monthData.put("absent", rs.getInt("absent"));
                data.add(monthData);
            }
        }
        return data;
    }
    
    // Get attendance summary for date range
    public List<Map<String, Object>> getAttendanceSummary(int teacherId, String startDate, 
                                                          String endDate, String className) throws SQLException {
        List<Map<String, Object>> summary = new ArrayList<>();
        String sql = "SELECT u.id, u.roll_no, u.full_name, u.class, " +
                     "COUNT(a.id) as total_days, " +
                     "SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_days, " +
                     "SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_days, " +
                     "ROUND((SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) / COUNT(a.id)) * 100, 2) as percentage " +
                     "FROM users u " +
                     "LEFT JOIN attendance a ON u.id = a.student_id " +
                     "AND a.attendance_date BETWEEN ? AND ? " +
                     "WHERE u.role = 'student' " +
                     "AND (? = 'all' OR u.class = ?) " +
                     "AND (u.class IN (SELECT class FROM users WHERE id = ?) OR ? = 0) " +
                     "GROUP BY u.id " +
                     "ORDER BY percentage DESC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, startDate);
            pstmt.setString(2, endDate);
            pstmt.setString(3, className);
            pstmt.setString(4, className);
            pstmt.setInt(5, teacherId);
            pstmt.setInt(6, teacherId);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("id", rs.getInt("id"));
                record.put("rollNo", rs.getString("roll_no"));
                record.put("fullName", rs.getString("full_name"));
                record.put("className", rs.getString("class"));
                record.put("totalDays", rs.getInt("total_days"));
                record.put("presentDays", rs.getInt("present_days"));
                record.put("absentDays", rs.getInt("absent_days"));
                record.put("percentage", rs.getDouble("percentage"));
                summary.add(record);
            }
        }
        return summary;
    }
    
    // Get student's recent attendance records
    public List<Map<String, Object>> getStudentRecentAttendance(int studentId, int limit) throws SQLException {
        List<Map<String, Object>> records = new ArrayList<>();
        String sql = "SELECT attendance_date, status, remarks " +
                     "FROM attendance " +
                     "WHERE student_id = ? " +
                     "ORDER BY attendance_date DESC LIMIT ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentId);
            pstmt.setInt(2, limit);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("date", rs.getDate("attendance_date"));
                record.put("status", rs.getString("status"));
                record.put("remarks", rs.getString("remarks"));
                records.add(record);
            }
        }
        return records;
    }
    
    // Update attendance record
    public boolean updateAttendance(int attendanceId, String status, String remarks) throws SQLException {
        String sql = "UPDATE attendance SET status = ?, remarks = ?, marked_at = CURRENT_TIMESTAMP " +
                     "WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setString(2, remarks);
            pstmt.setInt(3, attendanceId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    // Delete attendance record
    public boolean deleteAttendance(int attendanceId) throws SQLException {
        String sql = "DELETE FROM attendance WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, attendanceId);
            return pstmt.executeUpdate() > 0;
        }
    }
    
    // Helper method to extract Attendance from ResultSet
    private Attendance extractAttendanceFromResultSet(ResultSet rs) throws SQLException {
        Attendance attendance = new Attendance();
        attendance.setId(rs.getInt("id"));
        attendance.setStudentId(rs.getInt("student_id"));
        attendance.setTeacherId(rs.getInt("teacher_id"));
        attendance.setAttendanceDate(rs.getDate("attendance_date"));
        attendance.setStatus(rs.getString("status"));
        attendance.setRemarks(rs.getString("remarks"));
        attendance.setMarkedAt(rs.getTimestamp("marked_at"));
        return attendance;
    }
}