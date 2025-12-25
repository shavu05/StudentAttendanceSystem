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

import org.json.JSONObject;

import com.attendance.util.DatabaseConnection;

@WebServlet("/StudentServlet")
public class StudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
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
        
        System.out.println("===== StudentServlet Debug =====");
        System.out.println("Action: " + action);

        try {
            if (action == null) action = "";

            switch (action) {
                case "getYearlyReport":
                    getYearlyReport(request, out);
                    break;

                case "getMonthlyReport":
                    getMonthlyReport(request, out);
                    break;

                default:
                    out.print("{\"success\":false,\"message\":\"Invalid action: " + action + "\"}");
                    System.out.println("Invalid action received: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error in StudentServlet: " + e.getMessage());
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    // ===============================
    // GET YEARLY REPORT FOR STUDENT
    // ===============================
    private void getYearlyReport(HttpServletRequest request, PrintWriter out) throws Exception {
        String studentIdStr = request.getParameter("studentId");
        String year = request.getParameter("year");

        System.out.println("Getting yearly report for student: " + studentIdStr + ", year: " + year);

        if (studentIdStr == null || year == null) {
            System.out.println("Missing parameters!");
            out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int studentId = Integer.parseInt(studentIdStr);
        int yearInt = Integer.parseInt(year);

        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            System.out.println("Database connection successful");

            String sql = "SELECT " +
                        "COUNT(*) as total_days, " +
                        "SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) as present_days, " +
                        "SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) as absent_days " +
                        "FROM attendance " +
                        "WHERE student_id = ? AND YEAR(attendance_date) = ?";

            pst = conn.prepareStatement(sql);
            pst.setInt(1, studentId);
            pst.setInt(2, yearInt);

            System.out.println("Executing query: " + sql);
            System.out.println("Parameters: studentId=" + studentId + ", year=" + yearInt);

            rs = pst.executeQuery();

            JSONObject report = new JSONObject();

            if (rs.next()) {
                int total = rs.getInt("total_days");
                int present = rs.getInt("present_days");
                int absent = rs.getInt("absent_days");

                System.out.println("Query results - Total: " + total + ", Present: " + present + ", Absent: " + absent);

                report.put("totalDays", total);
                report.put("presentDays", present);
                report.put("absentDays", absent);
                
                if (total > 0) {
                    double percentage = (present * 100.0) / total;
                    report.put("percentage", String.format("%.1f", percentage));
                } else {
                    report.put("percentage", "0.0");
                }
            } else {
                System.out.println("No data found for this student/year");
                report.put("totalDays", 0);
                report.put("presentDays", 0);
                report.put("absentDays", 0);
                report.put("percentage", "0.0");
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("report", report);

            String jsonResponse = result.toString();
            System.out.println("Sending response: " + jsonResponse);
            out.print(jsonResponse);

        } catch (Exception e) {
            System.err.println("Error in getYearlyReport: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pst != null) try { pst.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ===============================
    // GET MONTHLY REPORT FOR STUDENT
    // ===============================
    private void getMonthlyReport(HttpServletRequest request, PrintWriter out) throws Exception {
        String studentIdStr = request.getParameter("studentId");
        String month = request.getParameter("month");
        String year = request.getParameter("year");

        System.out.println("Getting monthly report for student: " + studentIdStr + 
                         ", month: " + month + ", year: " + year);

        if (studentIdStr == null || month == null || year == null) {
            System.out.println("Missing parameters!");
            out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int studentId = Integer.parseInt(studentIdStr);
        int monthInt = Integer.parseInt(month);
        int yearInt = Integer.parseInt(year);

        Connection conn = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            System.out.println("Database connection successful");

            String sql = "SELECT " +
                        "COUNT(*) as total_days, " +
                        "SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) as present_days, " +
                        "SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) as absent_days " +
                        "FROM attendance " +
                        "WHERE student_id = ? AND MONTH(attendance_date) = ? AND YEAR(attendance_date) = ?";

            pst = conn.prepareStatement(sql);
            pst.setInt(1, studentId);
            pst.setInt(2, monthInt);
            pst.setInt(3, yearInt);

            System.out.println("Executing query: " + sql);
            System.out.println("Parameters: studentId=" + studentId + 
                             ", month=" + monthInt + ", year=" + yearInt);

            rs = pst.executeQuery();

            JSONObject report = new JSONObject();

            if (rs.next()) {
                int total = rs.getInt("total_days");
                int present = rs.getInt("present_days");
                int absent = rs.getInt("absent_days");

                System.out.println("Query results - Total: " + total + ", Present: " + present + ", Absent: " + absent);

                report.put("totalDays", total);
                report.put("presentDays", present);
                report.put("absentDays", absent);
                
                if (total > 0) {
                    double percentage = (present * 100.0) / total;
                    report.put("percentage", String.format("%.1f", percentage));
                } else {
                    report.put("percentage", "0.0");
                }
            } else {
                System.out.println("No data found for this student/month/year");
                report.put("totalDays", 0);
                report.put("presentDays", 0);
                report.put("absentDays", 0);
                report.put("percentage", "0.0");
            }

            JSONObject result = new JSONObject();
            result.put("success", true);
            result.put("report", report);

            String jsonResponse = result.toString();
            System.out.println("Sending response: " + jsonResponse);
            out.print(jsonResponse);

        } catch (Exception e) {
            System.err.println("Error in getMonthlyReport: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pst != null) try { pst.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}