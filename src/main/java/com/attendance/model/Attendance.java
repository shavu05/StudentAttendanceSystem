package com.attendance.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Attendance {
    private int id;
    private int studentId;
    private int teacherId;
    private Date attendanceDate;
    private String status; // present, absent, late, excused
    private String remarks;
    private Timestamp markedAt;
    
    // Constructors
    public Attendance() {}
    
    public Attendance(int studentId, int teacherId, Date attendanceDate, String status) {
        this.studentId = studentId;
        this.teacherId = teacherId;
        this.attendanceDate = attendanceDate;
        this.status = status;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    
    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }
    
    public Date getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(Date attendanceDate) { this.attendanceDate = attendanceDate; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    
    public Timestamp getMarkedAt() { return markedAt; }
    public void setMarkedAt(Timestamp markedAt) { this.markedAt = markedAt; }
}