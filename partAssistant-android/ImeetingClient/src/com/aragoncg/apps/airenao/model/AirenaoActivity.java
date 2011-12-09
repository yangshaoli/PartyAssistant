package com.aragoncg.apps.airenao.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * 
 * ClassName:AirenaoActivity
 * Function: to record one airenao activity
 * @author   cuikuangye
 * @version  
 * @Date	 2011	2011-11-5		pm 1:13:26
 * @see 	 
 *
 */
public class AirenaoActivity implements Serializable{
	/**
	 * serialVersionUID:TODO（......）
	 * 
	 * @since Ver 1.1
	 */
	
	private static final long serialVersionUID = 1L;
	private int id ;
	private String activityName;
	private String activityTime;
	private String activityPosition;
	private int peopleLimitNum;
	private String activityContent;
	private int invitedPeople;
	private int signUp;
	private int unSignUp;
	private int unJoin;
	private String sendType;
	private List<Map<String,Object>> peopleList;
	
	
	
	public String getSendType() {
		return sendType;
	}

	public void setSendType(String sendType) {
		this.sendType = sendType;
	}

	public List<Map<String, Object>> getPeopleList() {
		return peopleList;
	}

	public void setPeopleList(List<Map<String, Object>> peopleList) {
		this.peopleList = peopleList;
	}

	public AirenaoActivity() {
		
		super();
		
	}

	public AirenaoActivity(String activityName, String activityTime,
			String activityPosition, int peopleLimitNum, String activityContent) {
		this.activityName = activityName;
		this.activityTime = activityTime;
		this.activityPosition = activityPosition;
		this.peopleLimitNum = peopleLimitNum;
		this.activityContent = activityContent;
	}

	public String getActivityName() {
		return activityName;
	}
	
	public void setActivityName(String activityName) {
		this.activityName = activityName;
	}
	
	public String getActivityTime() {
		return activityTime;
	}
	public void setActivityTime(String activityTime) {
		this.activityTime = activityTime;
	}
	
	public String getActivityPosition() {
		return activityPosition;
	}
	
	public void setActivityPosition(String activityPosition) {
		this.activityPosition = activityPosition;
	}
	
	public int getPeopleLimitNum() {
		return peopleLimitNum;
	}
	
	public void setPeopleLimitNum(int peopleLimitNum) {
		this.peopleLimitNum = peopleLimitNum;
	}
	
	public String getActivityContent() {
		return activityContent;
	}
	
	public void setActivityContent(String activityContent) {
		this.activityContent = activityContent;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getInvitedPeople() {
		return invitedPeople;
	}

	public void setInvitedPeople(int invitedPeople) {
		this.invitedPeople = invitedPeople;
	}

	public int getSignUp() {
		return signUp;
	}

	public void setSignUp(int signUp) {
		this.signUp = signUp;
	}

	public int getUnSignUp() {
		return unSignUp;
	}

	public void setUnSignUp(int unSignUp) {
		this.unSignUp = unSignUp;
	}

	public int getUnJoin() {
		return unJoin;
	}

	public void setUnJoin(int unJoin) {
		this.unJoin = unJoin;
	}
	
	
	
}
