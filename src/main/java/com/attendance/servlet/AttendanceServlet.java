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

    // ===============================
    // DO GET
    // ===============================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    // ===============================
    // DO POST
    // ===============================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    // ===============================
    // MAIN CONTROLLER
    // ===============================
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
            if (action == null) action = "";

            switch (action) {
                case "saveAttendance":
                    saveAttendance(request, out);
                    break;

                case "viewAttendance":
                    viewAttendance(request, out);
                    break;

                case "generateReport":
                    generateReport(request, out);
                    break;

                case "getChartData":
                    getChartData(out);
                    break;

                default:
                    out.print("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    // ===============================
    // SAVE ATTENDANCE
    // ===============================
    private void saveAttendance(HttpServletRequest request, PrintWriter out) throws Exception {

        String date = request.getParameter("date");
        String teacherIdStr = request.getParameter("teacherId");
        String attendanceJson = request.getParameter("attendance");

        if (date == null || attendanceJson == null) {
            out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
            return;
        }

        int teacherId = Integer.parseInt(teacherIdStr);

        JSONObject attendanceData = new JSONObject(attendanceJson);

        Connection conn = DatabaseConnection.getConnection();
        conn.setAutoCommit(false);

        String sql = "INSERT INTO attendance (student_id, attendance_date, status, marked_by, marked_at) "
                   + "VALUES (?, ?, ?, ?, NOW()) "
                   + "ON DUPLICATE KEY UPDATE status=VALUES(status), marked_by=VALUES(marked_by), marked_at=NOW()";

        PreparedStatement pst = conn.prepareStatement(sql);

        for (String studentId : attendanceData.keySet()) {
            pst.setInt(1, Integer.parseInt(studentId));
            pst.setString(2, date);
            pst.setString(3, attendanceData.getString(studentId));
            pst.setInt(4, teacherId);
            pst.addBatch();
        }

        pst.executeBatch();
        conn.commit();

        pst.close();
        conn.close();

        out.print("{\"success\":true,\"message\":\"Attendance saved successfully\"}");
    }

    // ===============================
    // VIEW ATTENDANCE
    // ===============================
    private void viewAttendance(HttpServletRequest request, PrintWriter out) throws Exception {

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String classFilter = request.getParameter("class");

        Connection conn = DatabaseConnection.getConnection();

        StringBuilder sql = new StringBuilder(
            "SELECT a.attendance_date, a.status, u.roll_no, u.full_name, u.class "
          + "FROM attendance a JOIN users u ON a.student_id = u.id "
          + "WHERE a.attendance_date BETWEEN ? AND ? "
        );

        if (classFilter != null && !classFilter.isEmpty()) {
            sql.append("AND u.class = ? ");
        }

        sql.append("ORDER BY a.attendance_date DESC, u.roll_no");

        PreparedStatement pst = conn.prepareStatement(sql.toString());
        pst.setString(1, startDate);
        pst.setString(2, endDate);

        if (classFilter != null && !classFilter.isEmpty()) {
            pst.setString(3, classFilter);
        }

        ResultSet rs = pst.executeQuery();

        JSONArray records = new JSONArray();

        while (rs.next()) {
            JSONObject obj = new JSONObject();
            obj.put("date", rs.getString("attendance_date"));
            obj.put("rollNo", rs.getString("roll_no"));
            obj.put("fullName", rs.getString("full_name"));
            obj.put("className", rs.getString("class"));
            obj.put("status", rs.getString("status"));
            records.put(obj);
        }

        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("records", records);

        rs.close();
        pst.close();
        conn.close();

        out.print(result.toString());
    }

    // ===============================
    // GENERATE REPORT
    // ===============================
    private void generateReport(HttpServletRequest request, PrintWriter out) throws Exception {

        String month = request.getParameter("month");
        String year = request.getParameter("year");
        String classFilter = request.getParameter("class");

        Connection conn = DatabaseConnection.getConnection();

        StringBuilder sql = new StringBuilder(
            "SELECT u.id, u.roll_no, u.full_name, u.class, "
          + "SUM(a.status='present') AS present_days, "
          + "SUM(a.status='absent') AS absent_days, "
          + "COUNT(a.id) AS total_days "
          + "FROM users u LEFT JOIN attendance a "
          + "ON u.id = a.student_id AND MONTH(a.attendance_date)=? AND YEAR(a.attendance_date)=? "
          + "WHERE u.role='student' AND u.is_active=1 "
        );

        if (classFilter != null && !classFilter.isEmpty()) {
            sql.append("AND u.class = ? ");
        }

        sql.append("GROUP BY u.id ORDER BY u.roll_no");

        PreparedStatement pst = conn.prepareStatement(sql.toString());
        pst.setInt(1, Integer.parseInt(month));
        pst.setInt(2, Integer.parseInt(year));

        if (classFilter != null && !classFilter.isEmpty()) {
            pst.setString(3, classFilter);
        }

        ResultSet rs = pst.executeQuery();

        JSONArray report = new JSONArray();

        while (rs.next()) {
            JSONObject obj = new JSONObject();
            int total = rs.getInt("total_days");
            int present = rs.getInt("present_days");

            obj.put("rollNo", rs.getString("roll_no"));
            obj.put("fullName", rs.getString("full_name"));
            obj.put("className", rs.getString("class"));
            obj.put("presentDays", present);
            obj.put("absentDays", rs.getInt("absent_days"));
            obj.put("totalDays", total);
            obj.put("percentage", total > 0 ? String.format("%.1f", (present * 100.0 / total)) : "0.0");

            report.put(obj);
        }

        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("report", report);

        rs.close();
        pst.close();
        conn.close();

        out.print(result.toString());
    }

    // ===============================
    // CHART DATA
    // ===============================
    private void getChartData(PrintWriter out) throws Exception {

        Connection conn = DatabaseConnection.getConnection();

        String sql = "SELECT attendance_date, "
                   + "SUM(status='present') AS present, "
                   + "SUM(status='absent') AS absent "
                   + "FROM attendance "
                   + "WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) "
                   + "GROUP BY attendance_date ORDER BY attendance_date";

        PreparedStatement pst = conn.prepareStatement(sql);
        ResultSet rs = pst.executeQuery();

        JSONArray labels = new JSONArray();
        JSONArray present = new JSONArray();
        JSONArray absent = new JSONArray();

        while (rs.next()) {
            labels.put(rs.getString("attendance_date"));
            present.put(rs.getInt("present"));
            absent.put(rs.getInt("absent"));
        }

        JSONObject chartData = new JSONObject();
        chartData.put("labels", labels);
        chartData.put("present", present);
        chartData.put("absent", absent);

        JSONObject result = new JSONObject();
        result.put("success", true);
        result.put("chartData", chartData);

        rs.close();
        pst.close();
        conn.close();

        out.print(result.toString());
    }
}
