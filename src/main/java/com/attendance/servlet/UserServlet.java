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
import java.util.Enumeration;  // ADD THIS IMPORT

@WebServlet("/UserServlet")
@MultipartConfig
public class UserServlet extends HttpServlet {
    private UserDAO userDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userDAO = new UserDAO();
            gson = new Gson();
            System.out.println("✅ UserServlet initialized successfully");
        } catch (Exception e) {
            System.err.println("❌ ERROR: Failed to initialize UserServlet: " + e.getMessage());
            e.printStackTrace();
            throw new ServletException("Failed to initialize UserServlet", e);
        }
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

        System.out.println("===== UserServlet.doGet() =====");
        System.out.println("Action: " + action);

        try {
            if ("getUser".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("id"));
                System.out.println("Fetching user ID: " + userId);
                
                User user = userDAO.getUserById(userId);

                if (user != null) {
                    user.setPassword(null); // don't expose password
                    out.print(gson.toJson(user));
                    System.out.println("✅ User data sent successfully for ID: " + userId);
                } else {
                    result.put("success", false);
                    result.put("message", "User not found");
                    out.print(gson.toJson(result));
                    System.out.println("❌ User not found for ID: " + userId);
                }

            } else if ("getStats".equals(action)) {
                System.out.println("Getting user statistics...");
                
                Map<String, Object> stats = new HashMap<>();
                
                // Get counts
                int totalUsers = userDAO.getTotalUsers();
                int totalAdmins = userDAO.getTotalUsersByRole("admin");
                int totalTeachers = userDAO.getTotalUsersByRole("teacher");
                int totalStudents = userDAO.getTotalUsersByRole("student");
                
                // Debug output
                System.out.println("Total Users: " + totalUsers);
                System.out.println("Admins: " + totalAdmins);
                System.out.println("Teachers: " + totalTeachers);
                System.out.println("Students: " + totalStudents);
                
                // Build response
                stats.put("totalUsers", totalUsers);
                stats.put("totalAdmins", totalAdmins);
                stats.put("totalTeachers", totalTeachers);
                stats.put("totalStudents", totalStudents);
                stats.put("success", true);
                stats.put("message", "Statistics retrieved successfully");

                out.print(gson.toJson(stats));
                System.out.println("✅ Statistics sent successfully");

            } else {
                result.put("success", false);
                result.put("message", "Invalid action: " + action);
                out.print(gson.toJson(result));
                System.out.println("❌ Invalid action: " + action);
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
            out.print(gson.toJson(result));
            System.err.println("❌ ERROR in UserServlet.doGet(): " + e.getMessage());
        }
    }

    /**
     * Handle POST requests (add, update, delete users)
     */
    @Override  // ONLY ONE @Override HERE
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Map<String, Object> result = new HashMap<>();

        System.out.println("===== UserServlet.doPost() =====");
        System.out.println("Action: " + action);
        
        // Debug: Print all parameters
        System.out.println("All parameters:");
        Enumeration<String> paramNames = request.getParameterNames();  // Now this will work
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            System.out.println("  " + paramName + " = " + paramValue);
        }

        try {
            // ... rest of your code remains the same ...
            if ("add".equals(action)) {
                System.out.println("=== ADD USER REQUEST ===");
                
                // Log all parameters for debugging
                System.out.println("Request Parameters:");
                Enumeration<String> params = request.getParameterNames();  // Fixed
                while (params.hasMoreElements()) {
                    String paramName = params.nextElement();
                    String paramValue = request.getParameter(paramName);
                    System.out.println("  " + paramName + ": " + paramValue);
                }
                
                User user = new User();
                user.setUsername(request.getParameter("username"));

                String password = request.getParameter("password");
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(hashPassword(password));
                    System.out.println("Password hashed successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Password is required");
                    out.print(gson.toJson(result));
                    System.out.println("❌ Password is empty");
                    return;
                }

                user.setFullName(request.getParameter("fullName"));
                user.setEmail(request.getParameter("email"));
                user.setPhone(getSafeParam(request, "phone"));
                user.setRole(request.getParameter("role"));
                user.setDepartment(getSafeParam(request, "department"));
                user.setSubjects(getSafeParam(request, "subjects"));
                user.setRollNo(getSafeParam(request, "rollNo"));
                
                String classNameParam = request.getParameter("className");
                user.setClassName(classNameParam != null ? classNameParam.trim() : "");
                
                String isActiveParam = request.getParameter("isActive");
                boolean isActive = "true".equals(isActiveParam) || "on".equals(isActiveParam) || "1".equals(isActiveParam);
                user.setActive(isActive);

                // Validate required fields
                if (user.getUsername() == null || user.getUsername().trim().isEmpty() ||
                    user.getEmail() == null || user.getEmail().trim().isEmpty() ||
                    user.getFullName() == null || user.getFullName().trim().isEmpty() ||
                    user.getRole() == null || user.getRole().trim().isEmpty()) {
                    
                    result.put("success", false);
                    result.put("message", "All required fields must be filled");
                    out.print(gson.toJson(result));
                    System.out.println("❌ Missing required fields");
                    return;
                }

                // Check if username already exists
                if (!userDAO.isUsernameAvailable(user.getUsername())) {
                    System.out.println("❌ Username already exists: " + user.getUsername());
                    result.put("success", false);
                    result.put("message", "Username already exists.");
                    out.print(gson.toJson(result));
                    return;
                }

                // Check if email already exists
                if (!userDAO.isEmailAvailable(user.getEmail())) {
                    System.out.println("❌ Email already exists: " + user.getEmail());
                    result.put("success", false);
                    result.put("message", "Email already exists.");
                    out.print(gson.toJson(result));
                    return;
                }

                // Add user to database
                System.out.println("Adding user to database...");
                boolean success = userDAO.addUser(user);
                
                if (success) {
                    result.put("success", true);
                    result.put("message", "User added successfully!");
                    System.out.println("✅ User added successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Failed to add user to database.");
                    System.out.println("❌ Failed to add user");
                }

            } else if ("update".equals(action)) {
                System.out.println("=== UPDATE USER REQUEST ===");
                
                int id = Integer.parseInt(request.getParameter("id"));
                System.out.println("Updating user ID: " + id);
                
                User existingUser = userDAO.getUserById(id);

                if (existingUser == null) {
                    result.put("success", false);
                    result.put("message", "User not found");
                    out.print(gson.toJson(result));
                    System.out.println("❌ User not found with ID: " + id);
                    return;
                }

                User user = new User();
                user.setId(id);
                user.setUsername(request.getParameter("username"));

                String password = request.getParameter("password");
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(hashPassword(password));
                    System.out.println("New password provided and hashed");
                } else {
                    user.setPassword(existingUser.getPassword());
                    System.out.println("Keeping existing password");
                }

                user.setFullName(request.getParameter("fullName"));
                user.setEmail(request.getParameter("email"));
                user.setPhone(getSafeParam(request, "phone"));
                user.setRole(request.getParameter("role"));
                user.setDepartment(getSafeParam(request, "department"));
                user.setSubjects(getSafeParam(request, "subjects"));
                user.setRollNo(getSafeParam(request, "rollNo"));
                
                String classNameParam = request.getParameter("className");
                user.setClassName(classNameParam != null ? classNameParam.trim() : "");

                String isActiveParam = request.getParameter("isActive");
                boolean isActive = "true".equals(isActiveParam) || "on".equals(isActiveParam) || "1".equals(isActiveParam);
                user.setActive(isActive);

                // Update user in database
                System.out.println("Updating user in database...");
                boolean success = userDAO.updateUser(user);
                
                if (success) {
                    result.put("success", true);
                    result.put("message", "User updated successfully!");
                    System.out.println("✅ User updated successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Failed to update user.");
                    System.out.println("❌ Failed to update user");
                }

            } else if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("id"));
                System.out.println("Deleting user ID: " + userId);
                
                boolean success = userDAO.deleteUser(userId);
                
                if (success) {
                    result.put("success", true);
                    result.put("message", "User deleted successfully!");
                    System.out.println("✅ User deleted successfully");
                } else {
                    result.put("success", false);
                    result.put("message", "Failed to delete user.");
                    System.out.println("❌ Failed to delete user");
                }

            } else {
                result.put("success", false);
                result.put("message", "Invalid action: " + action);
                System.out.println("❌ Invalid action: " + action);
            }

        } catch (NumberFormatException e) {
            result.put("success", false);
            result.put("message", "Invalid ID format");
            System.err.println("❌ Invalid ID format: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage());
            System.err.println("❌ ERROR in UserServlet.doPost(): " + e.getMessage());
        }

        System.out.println("Response: " + gson.toJson(result));
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
            System.err.println("❌ Error hashing password: " + e.getMessage());
            return password; // fallback
        }
    }
}