package com.attendance.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;
import com.attendance.util.DatabaseConnection;

/**
 * AttendanceServlet - Handles all attendance-related operations
 * Actions: saveAttendance, getAttendanceByDate, getReports, getStudentDetails
 */
@WebServlet("/AttendanceServlet")
public class AttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\":false,\"message\":\"Session expired\"}");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action != null ? action : "") {
                case "saveAttendance":
                    saveAttendance(request, response, out);
                    break;
                case "getAttendanceByDate":
                    getAttendanceByDate(request, response, out);
                    break;
                case "getTeacherStats":
                    getTeacherStats(request, response, out);
                    break;
                case "viewAttendance":
                    viewAttendance(request, response, out);
                    break;
                case "generateReport":
                    generateReport(request, response, out);
                    break;
                case "getChartData":
                    getChartData(request, response, out);
                    break;
                default:
                    out.print("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Save attendance for multiple students
     */
    private void saveAttendance(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String date = request.getParameter("date");
        String teacherIdStr = request.getParameter("teacherId");
        String attendanceJson = request.getParameter("attendance");
        
        System.out.println("=== SAVE ATTENDANCE DEBUG ===");
        System.out.println("Date: " + date);
        System.out.println("TeacherId: " + teacherIdStr);
        System.out.println("Attendance JSON: " + attendanceJson);
        
        if (date == null || attendanceJson == null) {
            out.print("{\"success\":false,\"message\":\"Missing required parameters\"}");
            return;
        }
        
        // FIX: Handle teacherId properly
        int teacherId = 0;
        if (teacherIdStr != null && !teacherIdStr.trim().isEmpty() && !teacherIdStr.equals("null")) {
            try {
                teacherId = Integer.parseInt(teacherIdStr);
            } catch (NumberFormatException e) {
                System.err.println("Invalid teacherId: " + teacherIdStr);
            }
        }
        
        // Get from session if teacherId is still 0
        if (teacherId == 0) {
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                teacherId = (Integer) session.getAttribute("userId");
                System.out.println("Using teacherId from session: " + teacherId);
            }
        }
        
        // Parse JSON attendance data
        JSONObject attendanceData = new JSONObject(attendanceJson);
        
        Connection conn = null;
        PreparedStatement pst = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Simple SQL without class_id
            String sql = "INSERT INTO attendance (student_id, attendance_date, status, marked_by, marked_at) " +
                        "VALUES (?, ?, ?, ?, NOW()) " +
                        "ON DUPLICATE KEY UPDATE status=VALUES(status), marked_by=VALUES(marked_by), marked_at=NOW()";
            
            pst = conn.prepareStatement(sql);
            
            int savedCount = 0;
            Iterator<String> keys = attendanceData.keys();
            
            while (keys.hasNext()) {
                String studentId = keys.next();
                String status = attendanceData.getString(studentId);
                
                System.out.println("Processing: StudentId=" + studentId + ", Status=" + status);
                
                pst.setInt(1, Integer.parseInt(studentId));
                pst.setString(2, date);
                pst.setString(3, status);
                pst.setInt(4, teacherId);
                
                pst.addBatch();
                savedCount++;
            }
            
            int[] results = pst.executeBatch();
            conn.commit();
            
            System.out.println("✅ Batch executed successfully. Rows affected: " + results.length);
            System.out.println("=== END DEBUG ===");
            
            out.print("{\"success\":true,\"message\":\"Attendance saved for " + savedCount + " students\"}");
            
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        } finally {
            if (pst != null) pst.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    /**
     * Get attendance records for a specific date
     */
    private void getAttendanceByDate(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String date = request.getParameter("date");
        String classFilter = request.getParameter("class");
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT u.id, u.roll_no, u.full_name, u.class, ");
            sql.append("COALESCE(a.status, 'not_marked') as status, ");
            sql.append("(SELECT COUNT(*) FROM attendance WHERE student_id=u.id AND status='present' AND MONTH(attendance_date)=MONTH(CURDATE())) as monthly_present, ");
            sql.append("(SELECT COUNT(*) FROM attendance WHERE student_id=u.id AND MONTH(attendance_date)=MONTH(CURDATE())) as monthly_total ");
            sql.append("FROM users u ");
            sql.append("LEFT JOIN attendance a ON u.id=a.student_id AND a.attendance_date=? ");
            sql.append("WHERE u.role='student' AND u.is_active=1 ");
            
            if (classFilter != null && !classFilter.isEmpty()) {
                sql.append("AND u.class=? ");
            }
            
            sql.append("ORDER BY u.class, u.roll_no");
            
            pst = conn.prepareStatement(sql.toString());
            pst.setString(1, date);
            
            if (classFilter != null && !classFilter.isEmpty()) {
                pst.setString(2, classFilter);
            }
            
            rs = pst.executeQuery();
            
            JSONArray students = new JSONArray();
            
            while (rs.next()) {
                JSONObject student = new JSONObject();
                student.put("id", rs.getInt("id"));
                student.put("rollNo", rs.getString("roll_no"));
                student.put("fullName", rs.getString("full_name"));
                student.put("className", rs.getString("class"));
                student.put("status", rs.getString("status"));
                
                int monthlyPresent = rs.getInt("monthly_present");
                int monthlyTotal = rs.getInt("monthly_total");
                double monthlyPercent = monthlyTotal > 0 ? (double) monthlyPresent / monthlyTotal * 100 : 0;
                student.put("monthlyPercent", String.format("%.1f", monthlyPercent));
                
                students.put(student);
            }
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("attendance", students);
            
            out.print(result.toString());
            
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Get dashboard statistics for teacher
     */
    private void getTeacherStats(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            JSONObject stats = new JSONObject();
            
            // Total students
            String sql1 = "SELECT COUNT(*) as total FROM users WHERE role='student' AND is_active=1";
            pst = conn.prepareStatement(sql1);
            rs = pst.executeQuery();
            if (rs.next()) {
                stats.put("totalStudents", rs.getInt("total"));
            }
            rs.close();
            pst.close();
            
            // Today's present
            String sql2 = "SELECT COUNT(*) as present FROM attendance WHERE attendance_date=CURDATE() AND status='present'";
            pst = conn.prepareStatement(sql2);
            rs = pst.executeQuery();
            if (rs.next()) {
                stats.put("todayPresent", rs.getInt("present"));
            }
            rs.close();
            pst.close();
            
            // Today's absent
            String sql3 = "SELECT COUNT(*) as absent FROM attendance WHERE attendance_date=CURDATE() AND status='absent'";
            pst = conn.prepareStatement(sql3);
            rs = pst.executeQuery();
            if (rs.next()) {
                stats.put("todayAbsent", rs.getInt("absent"));
            }
            rs.close();
            pst.close();
            
            // Recent activity (last 7 days)
            String sql4 = "SELECT attendance_date, " +
                         "COUNT(CASE WHEN status='present' THEN 1 END) as present_count, " +
                         "COUNT(CASE WHEN status='absent' THEN 1 END) as absent_count " +
                         "FROM attendance " +
                         "WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                         "GROUP BY attendance_date ORDER BY attendance_date DESC";
            pst = conn.prepareStatement(sql4);
            rs = pst.executeQuery();
            
            JSONArray recentActivity = new JSONArray();
            while (rs.next()) {
                JSONObject day = new JSONObject();
                day.put("date", rs.getString("attendance_date"));
                day.put("presentCount", rs.getInt("present_count"));
                day.put("absentCount", rs.getInt("absent_count"));
                
                int total = rs.getInt("present_count") + rs.getInt("absent_count");
                double percentage = total > 0 ? (double) rs.getInt("present_count") / total * 100 : 0;
                day.put("percentage", String.format("%.1f", percentage));
                
                recentActivity.put(day);
            }
            
            stats.put("recentActivity", recentActivity);
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("stats", stats);
            
            out.print(result.toString());
            
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * View attendance records between dates
     */
    private void viewAttendance(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String classFilter = request.getParameter("class");
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT a.attendance_date, u.roll_no, u.full_name, u.class, a.status ");
            sql.append("FROM attendance a ");
            sql.append("INNER JOIN users u ON a.student_id=u.id ");
            sql.append("WHERE a.attendance_date BETWEEN ? AND ? ");
            
            if (classFilter != null && !classFilter.isEmpty()) {
                sql.append("AND u.class=? ");
            }
            
            sql.append("ORDER BY a.attendance_date DESC, u.class, u.roll_no");
            
            pst = conn.prepareStatement(sql.toString());
            pst.setString(1, startDate);
            pst.setString(2, endDate);
            
            if (classFilter != null && !classFilter.isEmpty()) {
                pst.setString(3, classFilter);
            }
            
            rs = pst.executeQuery();
            
            JSONArray records = new JSONArray();
            
            while (rs.next()) {
                JSONObject record = new JSONObject();
                record.put("date", rs.getString("attendance_date"));
                record.put("rollNo", rs.getString("roll_no"));
                record.put("fullName", rs.getString("full_name"));
                record.put("className", rs.getString("class"));
                record.put("status", rs.getString("status"));
                records.put(record);
            }
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("records", records);
            
            out.print(result.toString());
            
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Generate monthly attendance report
     */
    private void generateReport(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String month = request.getParameter("month");
        String year = request.getParameter("year");
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "SELECT u.id, u.roll_no, u.full_name, u.class, " +
                        "COUNT(CASE WHEN a.status='present' THEN 1 END) as present_days, " +
                        "COUNT(CASE WHEN a.status='absent' THEN 1 END) as absent_days, " +
                        "COUNT(*) as total_days " +
                        "FROM users u " +
                        "LEFT JOIN attendance a ON u.id=a.student_id " +
                        "AND MONTH(a.attendance_date)=? AND YEAR(a.attendance_date)=? " +
                        "WHERE u.role='student' AND u.is_active=1 " +
                        "GROUP BY u.id " +
                        "ORDER BY u.class, u.roll_no";
            
            pst = conn.prepareStatement(sql);
            pst.setInt(1, Integer.parseInt(month));
            pst.setInt(2, Integer.parseInt(year));
            
            rs = pst.executeQuery();
            
            JSONArray report = new JSONArray();
            
            while (rs.next()) {
                JSONObject student = new JSONObject();
                student.put("id", rs.getInt("id"));
                student.put("rollNo", rs.getString("roll_no"));
                student.put("fullName", rs.getString("full_name"));
                student.put("className", rs.getString("class"));
                student.put("presentDays", rs.getInt("present_days"));
                student.put("absentDays", rs.getInt("absent_days"));
                student.put("totalDays", rs.getInt("total_days"));
                
                int totalDays = rs.getInt("total_days");
                double percentage = totalDays > 0 ? (double) rs.getInt("present_days") / totalDays * 100 : 0;
                student.put("percentage", String.format("%.1f", percentage));
                
                report.put(student);
            }
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("report", report);
            
            out.print(result.toString());
            
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Get chart data for last 7 days
     */
    private void getChartData(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "SELECT attendance_date, " +
                        "COUNT(CASE WHEN status='present' THEN 1 END) as present, " +
                        "COUNT(CASE WHEN status='absent' THEN 1 END) as absent " +
                        "FROM attendance " +
                        "WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                        "GROUP BY attendance_date ORDER BY attendance_date";
            
            pst = conn.prepareStatement(sql);
            rs = pst.executeQuery();
            
            JSONArray labels = new JSONArray();
            JSONArray presentData = new JSONArray();
            JSONArray absentData = new JSONArray();
            
            while (rs.next()) {
                labels.put(rs.getString("attendance_date"));
                presentData.put(rs.getInt("present"));
                absentData.put(rs.getInt("absent"));
            }
            
            JSONObject chartData = new JSONObject();
            chartData.put("labels", labels);
            chartData.put("present", presentData);
            chartData.put("absent", absentData);
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("chartData", chartData);
            
            out.print(result.toString());
            
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }
}