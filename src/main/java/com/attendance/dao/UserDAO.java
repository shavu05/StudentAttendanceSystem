package com.attendance.dao;

import com.attendance.model.User;
import com.attendance.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /**
     * ADD USER - Create new user
     */
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, password, full_name, email, phone, role, " +
                     "department, subjects, roll_no, class, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        System.out.println("===== DEBUG addUser() =====");
        System.out.println("Username: " + user.getUsername());
        System.out.println("Role: " + user.getRole());
        System.out.println("Class: " + user.getClassName());
        System.out.println("Email: " + user.getEmail());

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getPhone() != null ? user.getPhone() : "");
            pstmt.setString(6, user.getRole());
            pstmt.setString(7, user.getDepartment() != null ? user.getDepartment() : "");
            pstmt.setString(8, user.getSubjects() != null ? user.getSubjects() : "");
            pstmt.setString(9, user.getRollNo() != null ? user.getRollNo() : "");
            pstmt.setString(10, user.getClassName() != null ? user.getClassName() : "");
            pstmt.setBoolean(11, user.isActive());

            int rows = pstmt.executeUpdate();
            System.out.println("✅ User added successfully. Rows affected: " + rows);
            return rows > 0;

        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in addUser(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * UPDATE USER - Edit existing user
     */
    public boolean updateUser(User user) {
        String sql;
        System.out.println("===== DEBUG updateUser() =====");
        System.out.println("Updating user ID: " + user.getId());
        
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            sql = "UPDATE users SET username=?, password=?, full_name=?, email=?, phone=?, role=?, " +
                  "department=?, subjects=?, roll_no=?, class=?, is_active=? WHERE id=?";
        } else {
            sql = "UPDATE users SET username=?, full_name=?, email=?, phone=?, role=?, " +
                  "department=?, subjects=?, roll_no=?, class=?, is_active=? WHERE id=?";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int paramIndex = 1;
            pstmt.setString(paramIndex++, user.getUsername());

            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                pstmt.setString(paramIndex++, user.getPassword());
            }

            pstmt.setString(paramIndex++, user.getFullName());
            pstmt.setString(paramIndex++, user.getEmail());
            pstmt.setString(paramIndex++, user.getPhone() != null ? user.getPhone() : "");
            pstmt.setString(paramIndex++, user.getRole());
            pstmt.setString(paramIndex++, user.getDepartment() != null ? user.getDepartment() : "");
            pstmt.setString(paramIndex++, user.getSubjects() != null ? user.getSubjects() : "");
            pstmt.setString(paramIndex++, user.getRollNo() != null ? user.getRollNo() : "");
            pstmt.setString(paramIndex++, user.getClassName() != null ? user.getClassName() : "");
            pstmt.setBoolean(paramIndex++, user.isActive());
            pstmt.setInt(paramIndex, user.getId());

            int rows = pstmt.executeUpdate();
            System.out.println("✅ User updated successfully. Rows affected: " + rows);
            return rows > 0;

        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in updateUser(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * GET ALL USERS - For admin dashboard
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id";
        
        System.out.println("===== DEBUG getAllUsers() =====");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            System.out.println("✅ Database connection successful for getAllUsers");
            
            int count = 0;
            while (rs.next()) {
                User user = extractUserFromResultSet(rs);
                users.add(user);
                count++;
            }
            
            System.out.println("✅ Retrieved " + count + " users from database");

        } catch (SQLException e) {
            System.err.println("❌ ERROR in getAllUsers(): " + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }

    /**
     * GET USER BY ID
     */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        System.out.println("===== DEBUG getUserById() =====");
        System.out.println("Looking for user ID: " + id);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                System.out.println("✅ Found user ID: " + id);
                return extractUserFromResultSet(rs);
            } else {
                System.out.println("❌ User not found with ID: " + id);
            }

        } catch (SQLException e) {
            System.err.println("❌ ERROR in getUserById(): " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * DELETE USER
     */
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        
        System.out.println("===== DEBUG deleteUser() =====");
        System.out.println("Deleting user ID: " + id);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            int rows = pstmt.executeUpdate();
            
            if (rows > 0) {
                System.out.println("✅ User deleted successfully. Rows affected: " + rows);
                return true;
            } else {
                System.out.println("❌ No user found with ID: " + id);
                return false;
            }

        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in deleteUser(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * AUTHENTICATE USER
     */
    public User authenticate(String username, String password, String role) {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND password = ? AND role = ? AND is_active = true";
        
        System.out.println("===== DEBUG authenticate() =====");
        System.out.println("Username/Email: " + username);
        System.out.println("Role: " + role);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            pstmt.setString(2, username);
            pstmt.setString(3, password);
            pstmt.setString(4, role);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                User user = extractUserFromResultSet(rs);
                System.out.println("✅ Authentication successful for: " + user.getUsername());
                return user;
            } else {
                System.out.println("❌ Authentication failed for: " + username);
            }

        } catch (SQLException e) {
            System.err.println("❌ ERROR in authenticate(): " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * CHECK USERNAME AVAILABILITY
     */
    public boolean isUsernameAvailable(String username) {
        String sql = "SELECT COUNT(*) as count FROM users WHERE username = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt("count");
                boolean available = count == 0;
                System.out.println("Username '" + username + "' available: " + available);
                return available;
            }

        } catch (SQLException e) {
            System.err.println("❌ ERROR in isUsernameAvailable(): " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * CHECK EMAIL AVAILABILITY
     */
    public boolean isEmailAvailable(String email) {
        String sql = "SELECT COUNT(*) as count FROM users WHERE email = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt("count");
                boolean available = count == 0;
                System.out.println("Email '" + email + "' available: " + available);
                return available;
            }

        } catch (SQLException e) {
            System.err.println("❌ ERROR in isEmailAvailable(): " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * GET TOTAL USERS
     */
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) as count FROM users";
        
        System.out.println("===== DEBUG getTotalUsers() =====");

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("✅ Total users in database: " + count);
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ ERROR in getTotalUsers(): " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * GET TOTAL USERS BY ROLE
     */
    public int getTotalUsersByRole(String role) {
        String sql = "SELECT COUNT(*) as count FROM users WHERE role = ?";
        
        System.out.println("===== DEBUG getTotalUsersByRole() =====");
        System.out.println("Counting users with role: " + role);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, role);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("✅ Found " + count + " users with role: " + role);
                return count;
            }

        } catch (SQLException e) {
            System.err.println("❌ ERROR in getTotalUsersByRole(): " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * HELPER METHOD - Extract User from ResultSet
     */
    private User extractUserFromResultSet(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setRole(rs.getString("role"));
        user.setDepartment(rs.getString("department"));
        user.setSubjects(rs.getString("subjects"));
        user.setRollNo(rs.getString("roll_no"));
        user.setClassName(rs.getString("class"));
        user.setActive(rs.getBoolean("is_active"));

        try {
            user.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            // Column might not exist
        }

        try {
            user.setLastLogin(rs.getTimestamp("last_login"));
        } catch (SQLException e) {
            // Column might not exist
        }

        return user;
    }
    
    /**
     * UPDATE USER LOGIN TIME
     */
    public void updateLoginTime(int userId) {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
            System.out.println("Updated login time for user ID: " + userId);
            
        } catch (SQLException e) {
            System.err.println("Error updating login time: " + e.getMessage());
        }
    }
}