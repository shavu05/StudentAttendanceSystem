package com.attendance.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;
import com.attendance.util.DatabaseConnection;

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

    private void saveAttendance(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String date = request.getParameter("date");
        String teacherIdStr = request.getParameter("teacherId");
        String attendanceJson = request.getParameter("attendance");
        
        System.out.println("=== SAVE ATTENDANCE ===");
        System.out.println("Date: " + date);
        System.out.println("TeacherId: " + teacherIdStr);
        System.out.println("Attendance JSON: " + attendanceJson);
        
        if (date == null || attendanceJson == null) {
            out.print("{\"success\":false,\"message\":\"Missing required parameters\"}");
            return;
        }
        
        int teacherId = 0;
        if (teacherIdStr != null && !teacherIdStr.trim().isEmpty()) {
            try {
                teacherId = Integer.parseInt(teacherIdStr);
            } catch (NumberFormatException e) {
                System.err.println("Invalid teacherId: " + teacherIdStr);
            }
        }
        
        if (teacherId == 0) {
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                teacherId = (Integer) session.getAttribute("userId");
            }
        }
        
        JSONObject attendanceData = new JSONObject(attendanceJson);
        
        Connection conn = null;
        PreparedStatement pst = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            String sql = "INSERT INTO attendance (student_id, attendance_date, status, marked_by, marked_at) " +
                        "VALUES (?, ?, ?, ?, NOW()) " +
                        "ON DUPLICATE KEY UPDATE status=VALUES(status), marked_by=VALUES(marked_by), marked_at=NOW()";
            
            pst = conn.prepareStatement(sql);
            
            int savedCount = 0;
            for (String studentId : attendanceData.keySet()) {
                String status = attendanceData.getString(studentId);
                
                pst.setInt(1, Integer.parseInt(studentId));
                pst.setString(2, date);
                pst.setString(3, status);
                pst.setInt(4, teacherId);
                
                pst.addBatch();
                savedCount++;
            }
            
            pst.executeBatch();
            conn.commit();
            
            System.out.println("✅ Attendance saved for " + savedCount + " students");
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

    private void viewAttendance(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String classFilter = request.getParameter("class");
        
        System.out.println("=== VIEW ATTENDANCE ===");
        System.out.println("Start Date: " + startDate);
        System.out.println("End Date: " + endDate);
        System.out.println("Class Filter: " + classFilter);
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT a.attendance_date, u.roll_no, u.full_name, u.class, a.status ");
            sql.append("FROM attendance a ");
            sql.append("INNER JOIN users u ON a.student_id = u.id ");
            sql.append("WHERE u.is_active = 1 ");
            
            // Fix: Only add date filter if dates are provided
            if (startDate != null && !startDate.trim().isEmpty() && 
                endDate != null && !endDate.trim().isEmpty()) {
                sql.append("AND a.attendance_date BETWEEN ? AND ? ");
            }
            
            // Fix: Handle class filter properly - including empty string
            boolean hasClassFilter = classFilter != null && !classFilter.trim().isEmpty();
            if (hasClassFilter) {
                sql.append("AND u.class = ? ");
            }
            
            sql.append("ORDER BY a.attendance_date DESC, u.class, u.roll_no");
            
            System.out.println("SQL Query: " + sql.toString());
            
            pst = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            if (startDate != null && !startDate.trim().isEmpty() && 
                endDate != null && !endDate.trim().isEmpty()) {
                pst.setString(paramIndex++, startDate);
                pst.setString(paramIndex++, endDate);
            }
            
            if (hasClassFilter) {
                pst.setString(paramIndex++, classFilter);
            }
            
            rs = pst.executeQuery();
            
            JSONArray records = new JSONArray();
            
            while (rs.next()) {
                JSONObject record = new JSONObject();
                record.put("date", rs.getString("attendance_date"));
                record.put("rollNo", rs.getString("roll_no") != null ? rs.getString("roll_no") : "N/A");
                record.put("fullName", rs.getString("full_name"));
                record.put("className", rs.getString("class") != null ? rs.getString("class") : "N/A");
                record.put("status", rs.getString("status"));
                records.put(record);
            }
            
            System.out.println("✅ Found " + records.length() + " records");
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("records", records);
            
            out.print(result.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error in viewAttendance: " + e.getMessage());
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }

    private void generateReport(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        String month = request.getParameter("month");
        String year = request.getParameter("year");
        String classFilter = request.getParameter("class");
        
        System.out.println("=== GENERATE REPORT ===");
        System.out.println("Month: " + month);
        System.out.println("Year: " + year);
        System.out.println("Class Filter: '" + classFilter + "'");
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Fix: Simplified query without class filter issues
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT u.id, u.roll_no, u.full_name, u.class, ");
            sql.append("COALESCE(SUM(CASE WHEN a.status='present' THEN 1 ELSE 0 END), 0) as present_days, ");
            sql.append("COALESCE(SUM(CASE WHEN a.status='absent' THEN 1 ELSE 0 END), 0) as absent_days, ");
            sql.append("COALESCE(COUNT(a.id), 0) as total_days ");
            sql.append("FROM users u ");
            sql.append("LEFT JOIN attendance a ON u.id = a.student_id ");
            sql.append("AND MONTH(a.attendance_date) = ? AND YEAR(a.attendance_date) = ? ");
            sql.append("WHERE u.role = 'student' AND u.is_active = 1 ");
            
            // Fix: Proper class filtering
            boolean hasClassFilter = classFilter != null && !classFilter.trim().isEmpty();
            if (hasClassFilter) {
                sql.append("AND u.class = ? ");
            }
            
            sql.append("GROUP BY u.id, u.roll_no, u.full_name, u.class ");
            sql.append("ORDER BY u.class, u.roll_no");
            
            System.out.println("SQL Query: " + sql.toString());
            
            pst = conn.prepareStatement(sql.toString());
            pst.setInt(1, Integer.parseInt(month));
            pst.setInt(2, Integer.parseInt(year));
            
            if (hasClassFilter) {
                pst.setString(3, classFilter);
                System.out.println("Applied class filter: " + classFilter);
            }
            
            rs = pst.executeQuery();
            
            JSONArray report = new JSONArray();
            
            while (rs.next()) {
                JSONObject student = new JSONObject();
                student.put("id", rs.getInt("id"));
                student.put("rollNo", rs.getString("roll_no") != null ? rs.getString("roll_no") : "N/A");
                student.put("fullName", rs.getString("full_name"));
                student.put("className", rs.getString("class") != null ? rs.getString("class") : "N/A");
                student.put("presentDays", rs.getInt("present_days"));
                student.put("absentDays", rs.getInt("absent_days"));
                student.put("totalDays", rs.getInt("total_days"));
                
                int totalDays = rs.getInt("total_days");
                double percentage = totalDays > 0 ? (double) rs.getInt("present_days") / totalDays * 100 : 0;
                student.put("percentage", String.format("%.1f", percentage));
                
                report.put(student);
                System.out.println("Added student: " + rs.getString("full_name") + " - Total Days: " + totalDays);
            }
            
            System.out.println("✅ Generated report with " + report.length() + " students");
            
            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("report", report);
            
            out.print(result.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Error in generateReport: " + e.getMessage());
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }

    private void getChartData(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws Exception {
        
        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            String sql = "SELECT attendance_date, " +
                        "COALESCE(SUM(CASE WHEN status='present' THEN 1 ELSE 0 END), 0) as present, " +
                        "COALESCE(SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END), 0) as absent " +
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
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        } finally {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (conn != null) conn.close();
        }
    }
}