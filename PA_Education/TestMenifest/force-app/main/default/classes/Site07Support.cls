/**
 * Object		: Site07Support.cls
 * Function		: Lead로 Insert
 * Author		: Yohan.Kang.
 * Date			: 2013.10.7
 * Description	: 
 */
public without sharing class Site07Support {
	public String username {get; set;}
	public String Company {get; set;}
	public String email {get; set;}
	public string subject{get; set;}
	public string message{get; set;}
	public string InterestProduct{get; set;}
	public string LeadSource{get; set;}
	
	public boolean IsErrorIsCompany{get; set;}
	public boolean IsErrorIsName{get; set;}
	public boolean IsErrorIsEmail{get; set;}
	public boolean IsErrorValidEmail{get; set;}
	
	public boolean IsRegistedOk{get; set;}
	
	public Site07Support(){
		IsErrorIsName = false;
		IsErrorIsEmail = false;
		IsErrorValidEmail = false;
		IsRegistedOk = false;
	}
	
	public pageReference registerLead(){
		IsErrorIsName = false;
		IsErrorIsEmail = false;
		IsErrorValidEmail = false;
		IsErrorIsCompany = false;
		
		if(Company==null || Company==''){
			IsErrorIsCompany = true;
		}
		
		if(username==null || username==''){
			IsErrorIsName = true;
		}
		
		if(email==null || email==''){
			IsErrorIsEmail = true;
		}
		
		if(!IsErrorIsEmail && !validateEmail(email)){
			IsErrorValidEmail = true;
		}
		
		if(IsErrorIsCompany || IsErrorIsName || IsErrorIsEmail || IsErrorValidEmail){
			return null;
		}
		
		Lead__c LD = new Lead__c();
		//Lead LD = new Lead();
		Ld.Name = username;
		Ld.Company__c = Company;
		Ld.LeadSource__c = '웹';
		LD.Email__c = email;
		LD.InterestProduct__c = InterestProduct;
		LD.WebSubject__c = subject;
		LD.WebMessage__c = message;
		insert LD;
		
		IsRegistedOk = true;
		return null;
	}
	
	private Boolean validateEmail(String email) {
		Boolean res = true;
		
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
		Pattern MyPattern = Pattern.compile(emailRegex);
		Matcher MyMatcher = MyPattern.matcher(email);
		
		if (!MyMatcher.matches()) 
		    res = false;
		return res;	
	}
	
}




/*

<apex:page showHeader="false" standardStylesheets="false" controller="Site07Support">
<head>
	<meta charset="utf-8"/>
	<title>대유넥스티어,DaeU NexTier,Daeunextier</title>
	<meta name="fb_admins_meta_tag" content="daeunextier"/>
	<meta name="keywords" content="Daeunextier, Radian6, 대유넥티어, 데이터사이언티스트, 벨류인에이블러, 에반젤리스트"/>
	<meta name="description" content="클라우드 기반 솔루션 프로바이더로서 기업이 필요로 하는 어플리케이션을 일일이 구축하지 않고 즉시 활용할 수 있는 서비스를 제공함으로써 중견,중소 기업의 비용부담을 최소화하고 생산성 향상 및 고객가치 증진에 기여하고자 합니다. ㈜대유넥스티어에 보내주시는 관심과 성원에 감사를 드립니다."/>
    
    
    <apex:stylesheet value="{!URLFOR($Resource.DaeuWebsite, 'css/reset.css')}"/>
    <apex:stylesheet value="{!URLFOR($Resource.DaeuWebsite, 'css/layout.css')}"/>
    <apex:stylesheet value="{!URLFOR($Resource.DaeuWebsite, 'css/style.css')}"/>
    <apex:stylesheet value="{!URLFOR($Resource.DaeuWebsite, 'css/zerogrid.css')}"/>
    <apex:stylesheet value="{!URLFOR($Resource.DaeuWebsite, 'css/responsive.css')}"/>
  
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/jquery-1.6.js')}"/>
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/cufon-yui.js')}"/>
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/cufon-replace.js')}"/>
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/Swis721_Cn_BT_400.font.js')}"/>
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/Swis721_Cn_BT_700.font.js')}"/>
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/tabs.js')}"/>
	<apex:includeScript value="{!URLFOR($Resource.DaeuWebsite, 'js/css3-mediaqueries.js')}"/>
        
	<!--[if lt IE 9]>
  	<script type="text/javascript" src="js/html5.js"></script>
	<style type="text/css">
		.bg{ behavior: url(js/PIE.htc); }
	</style>
  <![endif]-->
	<!--[if lt IE 7]>
		<div style=' clear: both; text-align:center; position: relative;'>
			<a href="http://www.microsoft.com/windows/internet-explorer/default.aspx?ocid=ie6_countdown_bannercode"><img src="http://www.theie6countdown.com/images/upgrade.jpg" border="0"  alt="" /></a>
		</div>
	<![endif]-->
</head>
<body id="page3">
	<div class="body1">
		<div class="body2">
			<div class="body5">
				<div class="main zerogrid">
				<!-- header -->
					<header>
						<div class="wrapper row"> 
		          			<h1><a href="index.html" id="logo"><apex:image value="{!URLFOR($Resource.DaeuWebsite, 'images/logo1.png')}" alt=""/></a></h1>
							<nav>
								<ul id="menu">
									<li id="nav1"><a href="/">Home</a></li>
									<li id="nav2"><a href="/AboutUs">About Us</a></li>
									<li id="nav3"><a href="/Service">Services</a></li>
									<li id="nav4"><a href="/MarketingCloud">Salesforce.com</a></li>
									<li id="nav5"><a href="/Clients">Clients</a></li>
									<li id="nav6"><a href="/Careers">Careers</a></li>
									<li id="nav7" class="active"><a href="/Support">Support</a></li>
						
								</ul>
							</nav>
						</div>
					</header>
				<!-- header end-->
				</div>
			</div>
		</div>
	</div>
	
<div class="body3">
	<div class="main zerogrid">
	<!-- content -->
		<article id="content">
			<div class="wrapper">
				<h2 class="under">Support</h2>
					<div class="wrapper">
						<section class="col-full">
							<!--
							<form id="ContactForm" method="post">
							-->
							
								<div>
									<div  class="wrapper" style="min-height:30px">
									
									
						    			<strong>당사 서비스에 관심을 보여주신점 감사드립니다. 
						    			<br></br>당사 서비스에 대한 문의는 아래 Contact Us를 통해 요청해주시기 바랍니다.</strong>
									</div>
									<p></p>
									
									<apex:form id="contactform">
									
									<div  class="wrapper" style="min-height:30px">
										<span style="width:109px;float:left;line-height:26px">+ Name :</span>
										<apex:inputText disabled="{!IsRegistedOk}" id="username" style="width:549px;height:18px;border:1px solid #e5e5e5;background:#fff;padding:3px 5px;color:#696968;font:14px 돋움, 'Trebuchet MS', Arial, Helvetica, sans-serif;font-style::italic;margin:0" value="{!username}"/>
										<apex:outputPanel rendered="{!IsErrorIsName}" id="thePanel">
											<strong style="color:red;">이름은 필수 입력입니다.</strong>
										</apex:outputPanel>
									</div>
									
									<div  class="wrapper" style="min-height:30px">
										<span style="width:109px;float:left;line-height:26px">+ Email :</span>
										
										
										<apex:inputText disabled="{!IsRegistedOk}" id="email" style="width:549px;height:18px;border:1px solid #e5e5e5;background:#fff;padding:3px 5px;color:#696968;font:14px 돋움, 'Trebuchet MS', Arial, Helvetica, sans-serif;font-style::italic;margin:0" value="{!email}"/>
												
												<apex:outputPanel rendered="{!IsErrorIsEmail}" id="thePane2">
													<strong style="color:red;">이메일은 필수 입력입니다.</strong>
												</apex:outputPanel>
												<apex:outputPanel rendered="{!IsErrorValidEmail}" id="thePane3">
													<strong style="color:red;">이메일형식이 잘못되었습니다.</strong>
												</apex:outputPanel>
										
									</div>
							
									<div  class="wrapper" style="min-height:30px">
										<span style="width:109px;float:left;line-height:26px">+ Subject : </span>
										
										<apex:inputText disabled="{!IsRegistedOk}" id="subject" style="width:549px;height:18px;border:1px solid #e5e5e5;background:#fff;padding:3px 5px;color:#696968;font:14px 돋움, 'Trebuchet MS', Arial, Helvetica, sans-serif;font-style::italic;margin:0" value="{!subject}"/>
														
										
									</div>
									
									<div  class="textarea_box" style="min-height:275px;width:100%;overflow:hidden;padding-bottom:6px">
										<span style="width:109px;float:left;line-height:26px">+ Message:</span>
										<apex:inputTextarea disabled="{!IsRegistedOk}" id="message" rows="10" value="{!message}" style="overflow:auto;width:549px;height:258px;border:1px solid #e5e5e5;background:#fff;padding:3px 5px;color:#696968;font:14px 'Trebuchet MS', Arial, Helvetica, sans-serif;font-style:italic;margin:0"  />
									</div>
									
									<div  class="wrapper" style="min-height:30px">
										<span style="width:109px;float:left;line-height:26px">&nbsp;</span>
										<apex:commandButton action="{!registerLead}" value="Send" id="submit" rerender="contactform" rendered="{!!IsRegistedOk}" style="cursor:pointer;margin-right:15px; float:left;width:62px;font-style:normal;font-weight:bold;color:#fff;height:32px;line-height:32px;text-decoration:none;background:#60b000;text-align:center" />

										<!--
										<apex:commandButton rendered="{! !IsRegistedOk}" styleClass="button" action="{!registerLead}" value="Send" id="submit" rerender="contactform"/>
										-->
										<apex:outputPanel rendered="{!IsRegistedOk}" id="thePane4">
											<strong>문의가 접수되었습니다. 등록하신 이메일로 회신을 드리겠습니다. 감사드립니다.</strong>
										</apex:outputPanel>
									</div>
									
									
									</apex:form>
																
									<!--
									<a href="#" onClick="document.getElementById('ContactForm').submit()">Send</a>
									
									
									<a href="#" onClick="document.getElementById('ContactForm').reset()">Clear</a>
									-->
								</div>
							
							
						</section>
					</div>
			</div>
		</article>
	</div>
</div>
<div class="body4">
	<div class="main zerogrid">
		<section class="col-3-4">
				<div class="wrap-col">
					<h4>Contact Us</h4>
					<ul class="address">
						<li><span>+  Address</span>서울특별시 강남구 테헤란로34길 14 (역삼동,정인빌딩 4층) </li>
						<li><span>+  CEO</span>최현택</li>
						<li><span>+  TEL </span>082-02-553-9981</li>
						<li><span>+  FAX </span>082-02-553-9967</li>
						<li><span>+  Email:</span><a href="mailto:">info@daeunextier.com</a></li>
					</ul>
				</div>
		</section>
		<section class="col-1-4">
				<div class="wrap-col">
					<h4>Follow Us</h4>
					<ul id="icons">
						<li><a href="https://www.facebook.com/daeunextier" target="_blank"><apex:image value="{!URLFOR($Resource.DaeuWebsite, 'images/icon1.png')}" alt=""/>Facebook</a></li>
						<li><a href="https://twitter.com/daeunextier" target="_blank"><apex:image value="{!URLFOR($Resource.DaeuWebsite, 'images/icon2.png')}" alt=""/>Twitter</a></li>
						<li><a href="http://blog.daeunextier.com" target="_blank"><apex:image value="{!URLFOR($Resource.DaeuWebsite, 'images/icon3.png')}" alt=""/>Blog</a></li>
					</ul>
				</div>
		</section>	
	</div>
</div>
<!-- footer -->	
 <div class="body6">
	<div class="main zerogrid">
		<section class="col-1-4">
			<div class="wrap-col"> <a href="index.html" id="logo"><apex:image value="{!URLFOR($Resource.DaeuWebsite, 'images/logo1.png')}" width="188" height="63" alt=""/></a> </div>
		</section>	
		
		<section class="col-1-2"> 
    		<div class="wrap-col">
				<nav>
					<ul id="menu2">
						<li id="nav1"><a href="/">Home</a></li>
							<li id="nav2"><a href="/AboutUs">About Us</a></li>
							<li id="nav3"><a href="/Service">Services</a></li>
							<li id="nav4"><a href="/MarketingCloud">Salesforce.com</a></li>
							<li id="nav5"><a href="/Clients">Clients</a></li>
							<li id="nav6"><a href="/Careers">Careers</a></li>
							<li id="nav7" class="active"><a href="/Support">Support</a></li>
					</ul>
				</nav>
			</div>
		</section>
		<section class="col-1-4">
			<div class="wrap-col" style="font-size:14px;">
				ⓒ Copyright 2013 DaeU Nextier
			</div>
		</section>
	</div>
</div>

<!-- footer end 

<script type="text/javascript"> Cufon.now(); </script>
	<script>
		$(document).ready(function() {
			tabs.init();
			})
	</script>
-->
</body>
</apex:page>
*/