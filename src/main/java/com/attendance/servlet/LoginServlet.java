package com.attendance.servlet;

import com.attendance.dao.UserDAO;
import com.attendance.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/LoginServlet"})
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
        
        String action = request.getParameter("action");
        
        // ============================================
        // HANDLE LOGOUT ACTION
        // ============================================
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                String username = (String) session.getAttribute("username");
                String role = (String) session.getAttribute("role");
                System.out.println("✅ User logged out: " + username + " (Role: " + role + ")");
                session.invalidate();
            }
            response.sendRedirect("login.jsp?message=Logged out successfully");
            return;
        }
        
        // ============================================
        // HANDLE LOGIN ACTION
        // ============================================
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        
        System.out.println("Login attempt - Username: " + username + ", Role: " + role);
        
        // Validate input
        if (username == null || password == null || role == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
            
            request.setAttribute("error", "❌ Please fill all fields");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        // HASH THE PASSWORD BEFORE AUTHENTICATION
        String hashedPassword = hashPassword(password);
        
        UserDAO userDAO = new UserDAO();
        User user = userDAO.authenticate(username, hashedPassword, role);
        
        if (user != null) {
            HttpSession session = request.getSession(true);
            
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("role", user.getRole());
            
            System.out.println("✅ Login SUCCESS: " + user.getFullName() + " logged in as " + user.getRole());
            System.out.println("Session created - User ID: " + user.getId());
            
            // Redirect based on role
            if ("admin".equals(user.getRole())) {
                response.sendRedirect("adminDashboard.jsp");
                return;
            } else if ("teacher".equals(user.getRole())) {
                response.sendRedirect("teacherDashboard.jsp");
                return;
            } else if ("student".equals(user.getRole())) {
                response.sendRedirect("studentDashboard.jsp");
                return;
            }
        } else {
            System.out.println("❌ Login FAILED: Invalid credentials for user: " + username);
            
            String errorMessage = "❌ Invalid username, password, or role. Please try again.";
            
            request.setAttribute("error", errorMessage);
            request.setAttribute("username", username);
            request.setAttribute("role", role);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Handle logout via GET request
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                String username = (String) session.getAttribute("username");
                String role = (String) session.getAttribute("role");
                System.out.println("✅ User logged out (GET): " + username + " (Role: " + role + ")");
                session.invalidate();
            }
            response.sendRedirect("login.jsp?message=Logged out successfully");
            return;
        }
        
        // For GET requests without action, show login page
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}