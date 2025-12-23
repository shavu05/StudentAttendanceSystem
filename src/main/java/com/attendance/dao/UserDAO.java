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
                     "department, subjects, roll_no, class, is_active, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

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

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * UPDATE USER - Edit existing user
     */
    public boolean updateUser(User user) {
        String sql;
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

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
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

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                users.add(extractUserFromResultSet(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    /**
     * GET USER BY ID
     */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * DELETE USER
     */
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * AUTHENTICATE USER
     */
    public User authenticate(String username, String password, String role) {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND password = ? AND role = ? AND is_active = true";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            pstmt.setString(2, username);
            pstmt.setString(3, password);
            pstmt.setString(4, role);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return extractUserFromResultSet(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * CHECK USERNAME AVAILABILITY
     */
    public boolean isUsernameAvailable(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) == 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * CHECK EMAIL AVAILABILITY
     */
    public boolean isEmailAvailable(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) == 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * GET TOTAL USERS
     */
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * GET TOTAL USERS BY ROLE
     */
    public int getTotalUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, role);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
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

        return user;
    }
}
