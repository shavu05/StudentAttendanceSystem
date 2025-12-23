package com.attendance.servlet;

import com.attendance.dao.UserDAO;
import com.attendance.model.User;
import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/UserServlet")
@MultipartConfig
public class UserServlet extends HttpServlet {
    private UserDAO userDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        gson = new Gson();
    }

    /**
     * Handle GET requests (fetch user details or stats)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            if ("getUser".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("id"));
                User user = userDAO.getUserById(userId);

                if (user != null) {
                    user.setPassword(null); // don’t expose password
                    out.print(gson.toJson(user));
                } else {
                    result.put("success", false);
                    result.put("message", "User not found");
                    out.print(gson.toJson(result));
                }

            } else if ("getStats".equals(action)) {
                Map<String, Object> stats = new HashMap<>();
                stats.put("totalUsers", userDAO.getTotalUsers());
                stats.put("totalAdmins", userDAO.getTotalUsersByRole("admin"));
                stats.put("totalTeachers", userDAO.getTotalUsersByRole("teacher"));
                stats.put("totalStudents", userDAO.getTotalUsersByRole("student"));
                stats.put("success", true);

                out.print(gson.toJson(stats));

            } else {
                result.put("success", false);
                result.put("message", "Invalid action");
                out.print(gson.toJson(result));
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
            out.print(gson.toJson(result));
        }
    }

    /**
     * Handle POST requests (add, update, delete users)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            System.out.println("=== SERVLET DEBUG: Action = " + action + " ===");

            if ("add".equals(action)) {
                User user = new User();
                user.setUsername(request.getParameter("username"));

                String password = request.getParameter("password");
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(hashPassword(password));
                } else {
                    result.put("success", false);
                    result.put("message", "Password is required");
                    out.print(gson.toJson(result));
                    return;
                }

                user.setFullName(request.getParameter("fullName"));
                user.setEmail(request.getParameter("email"));
                user.setPhone(getSafeParam(request, "phone"));
                user.setRole(request.getParameter("role"));
                user.setDepartment(getSafeParam(request, "department"));
                user.setSubjects(getSafeParam(request, "subjects"));
                user.setRollNo(getSafeParam(request, "rollNo"));
                user.setClassName(getSafeParam(request, "className"));

                String isActiveParam = request.getParameter("isActive");
                boolean isActive = "true".equals(isActiveParam) || "on".equals(isActiveParam) || "1".equals(isActiveParam);
                user.setActive(isActive);

                if (!userDAO.isUsernameAvailable(user.getUsername())) {
                    result.put("success", false);
                    result.put("message", "Username already exists.");
                    out.print(gson.toJson(result));
                    return;
                }

                if (!userDAO.isEmailAvailable(user.getEmail())) {
                    result.put("success", false);
                    result.put("message", "Email already exists.");
                    out.print(gson.toJson(result));
                    return;
                }

                boolean success = userDAO.addUser(user);
                result.put("success", success);
                result.put("message", success ? "User added successfully!" : "Failed to add user.");

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                User existingUser = userDAO.getUserById(id);

                if (existingUser == null) {
                    result.put("success", false);
                    result.put("message", "User not found");
                    out.print(gson.toJson(result));
                    return;
                }

                User user = new User();
                user.setId(id);
                user.setUsername(request.getParameter("username"));

                String password = request.getParameter("password");
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(hashPassword(password));
                } else {
                    user.setPassword(existingUser.getPassword());
                }

                user.setFullName(request.getParameter("fullName"));
                user.setEmail(request.getParameter("email"));
                user.setPhone(getSafeParam(request, "phone"));
                user.setRole(request.getParameter("role"));
                user.setDepartment(getSafeParam(request, "department"));
                user.setSubjects(getSafeParam(request, "subjects"));
                user.setRollNo(getSafeParam(request, "rollNo"));
                user.setClassName(getSafeParam(request, "className"));

                String isActiveParam = request.getParameter("isActive");
                boolean isActive = "true".equals(isActiveParam) || "on".equals(isActiveParam) || "1".equals(isActiveParam);
                user.setActive(isActive);

                boolean success = userDAO.updateUser(user);
                result.put("success", success);
                result.put("message", success ? "User updated successfully!" : "Failed to update user.");

            } else if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("id"));
                boolean success = userDAO.deleteUser(userId);
                result.put("success", success);
                result.put("message", success ? "User deleted successfully!" : "Failed to delete user.");

            } else {
                result.put("success", false);
                result.put("message", "Invalid action");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
        }

        System.out.println("Servlet Response: " + gson.toJson(result));
        out.print(gson.toJson(result));
    }

    /**
     * Utility method to safely get optional parameters
     */
    private String getSafeParam(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        return (value != null && !value.trim().isEmpty()) ? value.trim() : "";
    }

    /**
     * Password hashing method (SHA-256)
     */
    private String hashPassword(String password) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();

            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }

            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return password; // fallback
        }
    }
}
