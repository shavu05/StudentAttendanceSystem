package com.attendance.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String phone;
    private String role;
    private String department;
    private String subjects;
    private String rollNo;
    private String className; // This maps to 'class' column in database
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp lastLogin;
    
    // Constructors
    public User() {}
    
    public User(int id, String username, String fullName, String email, String role) {
        this.id = id;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    
    public String getSubjects() { return subjects; }
    public void setSubjects(String subjects) { this.subjects = subjects; }
    
    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }
    
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }
    
    // Helper methods
    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(role);
    }
    
    public boolean isTeacher() {
        return "teacher".equalsIgnoreCase(role);
    }
    
    public boolean isStudent() {
        return "student".equalsIgnoreCase(role);
    }
    
    @Override
    public String toString() {
        return "User [id=" + id + ", username=" + username + ", fullName=" + fullName + 
               ", email=" + email + ", role=" + role + ", isActive=" + isActive + "]";
    }
}