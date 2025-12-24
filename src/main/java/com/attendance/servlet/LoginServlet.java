package com.attendance.servlet;

import com.attendance.dao.UserDAO;
import com.attendance.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    // Password hashing method
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return password; // Fallback
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        
        System.out.println("Login attempt - Username: " + username + ", Role: " + role);
        System.out.println("DEBUG - Raw parameters:");
        System.out.println("Username: [" + username + "]");
        System.out.println("Password: [" + password + "]");
        System.out.println("Role: [" + role + "]");
        
        // Validate input
        if (username == null || password == null || role == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
            
            request.setAttribute("error", "❌ Please fill all fields");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        // HASH THE PASSWORD BEFORE AUTHENTICATION
        String hashedPassword = hashPassword(password);
        System.out.println("DEBUG: Hashed password: " + hashedPassword);
        
        UserDAO userDAO = new UserDAO();
        // Pass the HASHED password to authenticate method
        User user = userDAO.authenticate(username, hashedPassword, role);
        
     // In your LoginServlet.java, find the doPost method
     // Look for where you create the session after successful authentication
     // It should look something like this:

     if (user != null) {
         HttpSession session = request.getSession(true);
         
         session.setAttribute("user", user);
         session.setAttribute("userId", user.getId());     // ← ADD THIS LINE
         session.setAttribute("username", user.getUsername());
         session.setAttribute("fullName", user.getFullName());
         session.setAttribute("email", user.getEmail());
         session.setAttribute("role", user.getRole());
         
         System.out.println("✅ Login SUCCESS: " + user.getFullName() + " logged in as " + user.getRole());
         System.out.println("Session created - User ID: " + user.getId());
         
         // Redirect based on role
         if ("admin".equals(user.getRole())) {
             response.sendRedirect("adminDashboard.jsp");
         } else if ("teacher".equals(user.getRole())) {
             response.sendRedirect("teacherDashboard.jsp");
         } else if ("student".equals(user.getRole())) {
             response.sendRedirect("dashboard.jsp");
         }
     }
            
           
}}