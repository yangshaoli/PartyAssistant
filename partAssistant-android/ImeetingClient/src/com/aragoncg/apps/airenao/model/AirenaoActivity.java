package com.aragoncg.apps.airenao.model;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * 
 * ClassName:AirenaoActivity Function: to record one airenao activity
 * 
 * @author cuikuangye
 * @version
 * @Date 2011 2011-11-5 pm 1:13:26
 * @see
 * 
 */
public class AirenaoActivity implements Serializable {
	/**
	 * serialVersionUID:TODO（......）
	 * 
	 * @since Ver 1.1
	 */

	private static final long serialVersionUID = 1L;
	private String id;
	private String activityName;
	private String activityTime;
	private String activityPosition;
	private String peopleLimitNum;
	private String activityContent;
	private String invitedPeople;
	private String newInvitedPeople;
	private String newUnSignUP;
	private String signUp;
	private String unSignUp;
	private String unJoin;
	private String sendType;
	private int flagNew = 0;
	private List<Map<String, Object>> peopleList;
	private Map<String, String> clients;

	public Map<String, String> getClients() {
		return clients;
	}

	public void setClients(Map<String, String> clients) {
		this.clients = clients;
	}

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
			String activityPosition, String peopleLimitNum,
			String activityContent) {
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

	public String getPeopleLimitNum() {
		return peopleLimitNum;
	}

	public void setPeopleLimitNum(String peopleLimitNum) {
		this.peopleLimitNum = peopleLimitNum;
	}

	public String getActivityContent() {
		return activityContent;
	}

	public void setActivityContent(String activityContent) {
		this.activityContent = activityContent;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getInvitedPeople() {
		return invitedPeople;
	}

	public void setInvitedPeople(String invitedPeople) {
		this.invitedPeople = invitedPeople;
	}

	public String getSignUp() {
		return signUp;
	}

	public void setSignUp(String signUp) {
		this.signUp = signUp;
	}

	public String getUnSignUp() {
		return unSignUp;
	}

	public void setUnSignUp(String unSignUp) {
		this.unSignUp = unSignUp;
	}

	public String getUnJoin() {
		return unJoin;
	}

	public void setUnJoin(String unJoin) {
		this.unJoin = unJoin;
	}

	public String getNewInvitedPeople() {
		return newInvitedPeople;
	}

	public void setNewInvitedPeople(String newInvitedPeople) {
		this.newInvitedPeople = newInvitedPeople;
	}

	public String getNewUnSignUP() {
		return newUnSignUP;
	}

	public void setNewUnSignUP(String newUnSignUP) {
		this.newUnSignUP = newUnSignUP;
	}

	public int getFlagNew() {
		return flagNew;
	}

	public void setFlagNew(int flagNew) {
		this.flagNew = flagNew;
	}

}
