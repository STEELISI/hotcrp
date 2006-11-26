drop table if exists ImportantDates;
CREATE TABLE ImportantDates (
  name char(40) NOT NULL,
  start timestamp(14) NOT NULL,
  end timestamp(14) NOT NULL default 0,
  UNIQUE KEY name (name)
) TYPE=MyISAM;
insert into ImportantDates (name, start) values ('setupPhase', current_timestamp);


drop table if exists ActionLog;
CREATE TABLE ActionLog (
  logId int(11) NOT NULL auto_increment,
  contactId int(11) default NULL,
  paperId int(11) default NULL,
  time timestamp(14) NOT NULL,
  ipaddr varchar(16) default NULL,
  action varchar(120) default NULL,
  PRIMARY KEY  (logId),
  UNIQUE KEY logId (logId),
  KEY contactId (contactId),
  KEY paperId (paperId)
) TYPE=MyISAM;


drop table if exists ContactInfo;
CREATE TABLE ContactInfo (
  contactId int(11) NOT NULL auto_increment,
  visits int(11) NOT NULL default 0,
  firstName varchar(60) default NULL,
  lastName varchar(60) default NULL,
  email varchar(120) default NULL,
  affiliation varchar(200) default NULL,
  voicePhoneNumber varchar(24) default NULL,
  faxPhoneNumber varchar(24) default NULL,
  password varchar(32) default NULL,
  note varchar(200) default NULL,
  collaborators text,
  lastLogin int(11) NOT NULL default 0,
  PRIMARY KEY (contactId),
  UNIQUE KEY contactId (contactId),
  UNIQUE KEY email (email),
  KEY fullName (lastName,firstName,email),
  FULLTEXT KEY name (lastName,firstName,email),
  FULLTEXT KEY affiliation (affiliation),
  FULLTEXT KEY email_3 (email),
  FULLTEXT KEY firstName_2 (firstName),
  FULLTEXT KEY lastName (lastName)
) TYPE=MyISAM;


drop table if exists PCMember;
CREATE TABLE PCMember (
  contactId int(11) NOT NULL,
  UNIQUE KEY contactId (contactId)
) TYPE=MyISAM;


drop table if exists Chair;
CREATE TABLE Chair (
  contactId int(11) NOT NULL,
  UNIQUE KEY contactId (contactId)
) TYPE=MyISAM;


drop table if exists ChairAssistant;
CREATE TABLE ChairAssistant (
  contactId int(11) NOT NULL,
  UNIQUE KEY contactId (contactId)
) TYPE=MyISAM;


drop table if exists Paper;
CREATE TABLE Paper (
  paperId int(11) NOT NULL auto_increment,
  title varchar(200) default NULL,
  authorInformation text,
  abstract text,
  collaborators text,
  contactId int(11) default NULL,

  timeSubmitted int(11) NOT NULL default 0,
  timeWithdrawn int(11) NOT NULL default 0,
  timeFinalSubmitted int(11) NOT NULL default 0,
  pcPaper tinyint(11) NOT NULL default 0,

  paperStorageId int(11) NOT NULL default 0,
  finalPaperStorageId int(11) NOT NULL default 0,
  # copied from PaperStorage to reduce joins
  size int(11) NOT NULL default 0,
  mimetype varchar(40) NOT NULL default '',
  timestamp int(11) NOT NULL default 0,

  blind tinyint(1) NOT NULL default 1,
  authorsResponse mediumtext,
  outcome tinyint(1) NOT NULL default 0,
  showReviewsToReviewers tinyint(1) NOT NULL default 0,
  showResponseToReviewers tinyint(1) NOT NULL default 0,

  # calculated from PaperComment to reduce joins
  numComments int(11) NOT NULL default 0,
  numAuthorComments int(11) NOT NULL default 0,

  PRIMARY KEY (paperId),
  UNIQUE KEY paperId (paperId),
  KEY title (title),
  KEY contactId (contactId),
  FULLTEXT KEY titleAbstractText (title,abstract),
  FULLTEXT KEY allText (title,abstract,authorInformation,collaborators),
  FULLTEXT KEY authorText (authorInformation,collaborators)
) TYPE=MyISAM;


drop table if exists PaperStorage;
CREATE TABLE PaperStorage (
  paperStorageId int(11) NOT NULL auto_increment,
  paperId int(11) NOT NULL,
  timestamp int(11) NOT NULL,
  mimetype varchar(40) NOT NULL default '',
  paper longblob,
  compression tinyint(1) NOT NULL default 0,
  PRIMARY KEY (paperStorageId),
  UNIQUE KEY paperStorageId (paperStorageId),
  KEY paperId (paperId),
  KEY mimetype (mimetype)
) TYPE=MyISAM;

insert into PaperStorage set paperId=0, timestamp=0, mimetype='text/plain', paper='';


drop table if exists PaperConflict;
CREATE TABLE PaperConflict (
  paperId int(11) NOT NULL,
  contactId int(11) NOT NULL,
  author tinyint(1) NOT NULL default 0,
  UNIQUE KEY contactPaper (contactId,paperId),
  UNIQUE KEY contactPaperAuthor (contactId,paperId,author)
) TYPE=MyISAM;


drop table if exists PaperComment;
CREATE TABLE PaperComment (
  commentId int(11) NOT NULL auto_increment,
  contactId int(11) NOT NULL,
  paperId int(11) NOT NULL,
  timeModified int(11) NOT NULL,
  comment text NOT NULL default '',
  forReviewers tinyint(1) NOT NULL default 0,
  forAuthors tinyint(1) NOT NULL default 0,
  blind tinyint(1) NOT NULL default 1,
  PRIMARY KEY (commentId),
  UNIQUE KEY commentId (commentId),
  KEY contactId (contactId),
  KEY paperId (paperId)
) TYPE=MyISAM;


drop table if exists PaperTag;
CREATE TABLE PaperTag (
  paperId int(11) NOT NULL,
  tag varchar(40) NOT NULL,		# see TAG_MAXLEN in header.php
  UNIQUE KEY paperTag (paperId,tag)
) TYPE=MyISAM;


drop table if exists ChairTag;
CREATE TABLE ChairTag (
  tag varchar(40) NOT NULL,
  UNIQUE KEY tag (tag)
) TYPE=MyISAM;
insert into ChairTag (tag) values ('accept'), ('reject');


drop table if exists PaperGrade;
CREATE TABLE PaperGrade (
  gradeId int(11) NOT NULL auto_increment,
  contactId int(11) default NULL,
  paperId int(11) default NULL,
  time timestamp(14) NOT NULL,
  grade int(11) default NULL,
  PRIMARY KEY (gradeId),
  UNIQUE KEY gradeId (gradeId),
  KEY contactId (contactId),
  KEY paperId (paperId)
) TYPE=MyISAM;


drop table if exists PaperReview;
CREATE TABLE PaperReview (
  reviewId int(11) NOT NULL auto_increment,
  paperId int(11) NOT NULL,
  contactId int(11) NOT NULL,

  reviewType tinyint(1) NOT NULL default 0,
  requestedBy int(11) NOT NULL default 0,
  requestedOn timestamp(14) NOT NULL,
  acceptedOn timestamp(14) NOT NULL default 0,
  reviewBlind tinyint(1) NOT NULL default 1,

  reviewModified int(1),
  reviewSubmitted int(1),
  reviewOrdinal int(1),
  reviewNeedsSubmit tinyint(1) NOT NULL default 1,

  overAllMerit tinyint(1) NOT NULL default 0,
  reviewerQualification tinyint(1) NOT NULL default 0,
  novelty tinyint(1) NOT NULL default 0,
  technicalMerit tinyint(1) NOT NULL default 0,
  interestToCommunity tinyint(1) NOT NULL default 0,
  longevity tinyint(1) NOT NULL default 0,
  grammar tinyint(1) NOT NULL default 0,
  likelyPresentation tinyint(1) NOT NULL default 0,
  suitableForShort tinyint(1) NOT NULL default 0,
  paperSummary text NOT NULL default '',
  commentsToAuthor text NOT NULL default '',
  commentsToPC text NOT NULL default '',
  commentsToAddress text NOT NULL default '',
  weaknessOfPaper text NOT NULL default '',
  strengthOfPaper text NOT NULL default '',

  potential tinyint(4) NOT NULL default 0,
  fixability tinyint(4) NOT NULL default 0,

  PRIMARY KEY (reviewId),
  UNIQUE KEY reviewId (reviewId),
  UNIQUE KEY contactPaper (contactId,paperId),
  KEY paperId (paperId),
  KEY reviewSubmitted (reviewSubmitted),
  KEY reviewNeedsSubmit (reviewNeedsSubmit),
  KEY reviewType (reviewType),
  KEY requestedBy (requestedBy)
) TYPE=MyISAM;


drop table if exists PaperReviewRefused;
CREATE TABLE PaperReviewRefused (
  paperId int(11) NOT NULL,
  contactId int(11) NOT NULL,
  requestedBy int(11) NOT NULL,
  reason text NOT NULL default '',
  KEY paperId (paperId),
  KEY contactId (contactId),
  KEY requestedBy (requestedBy)
) TYPE=MyISAM;


drop table if exists PaperReviewArchive;
CREATE TABLE PaperReviewArchive (  
  reviewArchiveId int(11) NOT NULL auto_increment,
  reviewId int(11) NOT NULL,
  paperId int(11) NOT NULL,
  contactId int(11) NOT NULL,

  reviewType tinyint(1) NOT NULL default 0,
  requestedBy int(11) NOT NULL default 0,
  requestedOn timestamp(14) NOT NULL,
  acceptedOn timestamp(14) NOT NULL default 0,
  reviewBlind tinyint(1) NOT NULL default 1,

  reviewModified int(1),
  reviewSubmitted int(1),
  reviewOrdinal int(1),
  reviewNeedsSubmit tinyint(1) NOT NULL default 1,

  overAllMerit tinyint(1) NOT NULL default 0,
  reviewerQualification tinyint(1) NOT NULL default 0,
  novelty tinyint(1) NOT NULL default 0,
  technicalMerit tinyint(1) NOT NULL default 0,
  interestToCommunity tinyint(1) NOT NULL default 0,
  longevity tinyint(1) NOT NULL default 0,
  grammar tinyint(1) NOT NULL default 0,
  likelyPresentation tinyint(1) NOT NULL default 0,
  suitableForShort tinyint(1) NOT NULL default 0,
  paperSummary text NOT NULL default '',
  commentsToAuthor text NOT NULL default '',
  commentsToPC text NOT NULL default '',
  commentsToAddress text NOT NULL default '',
  weaknessOfPaper text NOT NULL default '',
  strengthOfPaper text NOT NULL default '',

  potential tinyint(4) NOT NULL default 0,
  fixability tinyint(4) NOT NULL default 0,

  PRIMARY KEY (reviewArchiveId),
  UNIQUE KEY reviewArchiveId (reviewArchiveId),
  KEY reviewId (reviewId),
  KEY contactPaper (contactId,paperId),
  KEY paperId (paperId),
  KEY reviewSubmitted (reviewSubmitted),
  KEY reviewNeedsSubmit (reviewNeedsSubmit),
  KEY reviewType (reviewType),
  KEY requestedBy (requestedBy)
) TYPE=MyISAM;


drop table if exists PaperReviewPreference;
CREATE TABLE PaperReviewPreference (
  paperId int(11) NOT NULL,
  contactId int(11) NOT NULL,
  preference int(4) NOT NULL default 0,
  UNIQUE KEY contactPaper (contactId,paperId)
) TYPE=MyISAM;


drop table if exists TopicArea;
CREATE TABLE TopicArea (
  topicId int(11) NOT NULL auto_increment,
  topicName varchar(80) default NULL,
  PRIMARY KEY (topicId),
  UNIQUE KEY topicId (topicId),
  KEY topicName (topicName)
) TYPE=MyISAM;


drop table if exists PaperTopic;
CREATE TABLE PaperTopic (
  topicId int(11) default NULL,
  paperId int(11) default NULL,
  UNIQUE KEY paperTopic (paperId,topicId)
) TYPE=MyISAM;


drop table if exists TopicInterest;
CREATE TABLE TopicInterest (
  contactId int(11) NOT NULL,
  topicId int(11) NOT NULL,
  interest int(1),
  UNIQUE KEY contactTopic (contactId,topicId)
) TYPE=MyISAM;


drop table if exists ReviewFormField;
create table ReviewFormField (
  fieldName varchar(25) NOT NULL,
  shortName varchar(40) NOT NULL,
  description text,
  sortOrder tinyint(1) NOT NULL default -1,
  rows tinyint(1) NOT NULL default 0,
  authorView tinyint(1) NOT NULL default 1,
  PRIMARY KEY (fieldName),
  UNIQUE KEY fieldName (fieldName),
  KEY shortName (shortName)
) TYPE=MyISAM;


drop table if exists ReviewFormOptions;
create table ReviewFormOptions (
  fieldName varchar(25) NOT NULL,
  level tinyint(1) NOT NULL,
  description text,
  KEY fieldName (fieldName),
  KEY level (level)
) TYPE=MyISAM;

insert into ReviewFormField set fieldName='overAllMerit',
	shortName='Overall merit', sortOrder=0;
insert into ReviewFormField set fieldName='reviewerQualification',
	shortName='Reviewer expertise', sortOrder=1;
insert into ReviewFormField set fieldName='novelty',
	shortName='Novelty';
insert into ReviewFormField set fieldName='technicalMerit',
	shortName='Technical merit';
insert into ReviewFormField set fieldName='interestToCommunity',
	shortName='Community interest';
insert into ReviewFormField set fieldName='longevity',
	shortName='Longevity', description='How important will this work be over time?';
insert into ReviewFormField set fieldName='grammar',
	shortName='Writing';
insert into ReviewFormField set fieldName='suitableForShort',
	shortName='Suitable for short paper';
insert into ReviewFormField set fieldName='paperSummary',
	shortName='Paper summary', sortOrder=2, rows=5;
insert into ReviewFormField set fieldName='commentsToAuthor',
	shortName='Comments for author', sortOrder=3, rows=15;
insert into ReviewFormField set fieldName='commentsToPC',
	shortName='Comments for PC', sortOrder=4, rows=10, authorView=0;
insert into ReviewFormField set fieldName='commentsToAddress',
	shortName='Comments to address in the response', rows=10;
insert into ReviewFormField set fieldName='weaknessOfPaper',
	shortName='Paper weakness', rows=5;
insert into ReviewFormField set fieldName='strengthOfPaper',
	shortName='Paper strengths', rows=5;
insert into ReviewFormField set fieldName='likelyPresentation',
	shortName='Numeric field 1';
insert into ReviewFormField set fieldName='potential',
	shortName='Numeric field 2';
insert into ReviewFormField set fieldName='fixability',
	shortName='Numeric field 3';

insert into ReviewFormOptions set fieldName='overAllMerit', level=1, description='Reject';
insert into ReviewFormOptions set fieldName='overAllMerit', level=2, description='Weak reject';
insert into ReviewFormOptions set fieldName='overAllMerit', level=3, description='Weak accept';
insert into ReviewFormOptions set fieldName='overAllMerit', level=4, description='Accept';
insert into ReviewFormOptions set fieldName='overAllMerit', level=5, description='Strong accept';

insert into ReviewFormOptions set fieldName='reviewerQualification', level=1, description='No familiarity';
insert into ReviewFormOptions set fieldName='reviewerQualification', level=2, description='Some familiarity';
insert into ReviewFormOptions set fieldName='reviewerQualification', level=3, description='Knowledgeable';
insert into ReviewFormOptions set fieldName='reviewerQualification', level=4, description='Expert';

insert into ReviewFormOptions set fieldName='novelty', level=1, description='Published before';
insert into ReviewFormOptions set fieldName='novelty', level=2, description='Done before (not necessarily published)';
insert into ReviewFormOptions set fieldName='novelty', level=3, description='Incremental improvement';
insert into ReviewFormOptions set fieldName='novelty', level=4, description='New contribution';
insert into ReviewFormOptions set fieldName='novelty', level=5, description='Surprisingly new contribution';

insert into ReviewFormOptions set fieldName='technicalMerit', level=1, description='Poor';
insert into ReviewFormOptions set fieldName='technicalMerit', level=2, description='Fair';
insert into ReviewFormOptions set fieldName='technicalMerit', level=3, description='Average';
insert into ReviewFormOptions set fieldName='technicalMerit', level=4, description='Good';
insert into ReviewFormOptions set fieldName='technicalMerit', level=5, description='Excellent';

insert into ReviewFormOptions set fieldName='interestToCommunity', level=1, description='None';
insert into ReviewFormOptions set fieldName='interestToCommunity', level=2, description='Low';
insert into ReviewFormOptions set fieldName='interestToCommunity', level=3, description='Average';
insert into ReviewFormOptions set fieldName='interestToCommunity', level=4, description='High';
insert into ReviewFormOptions set fieldName='interestToCommunity', level=5, description='Exciting';

insert into ReviewFormOptions set fieldName='longevity', level=1, description='Not important now or later';
insert into ReviewFormOptions set fieldName='longevity', level=2, description='Low importance';
insert into ReviewFormOptions set fieldName='longevity', level=3, description='Average importance';
insert into ReviewFormOptions set fieldName='longevity', level=4, description='Important';
insert into ReviewFormOptions set fieldName='longevity', level=5, description='Exciting';

insert into ReviewFormOptions set fieldName='grammar', level=1, description='Poor';
insert into ReviewFormOptions set fieldName='grammar', level=2, description='Fair';
insert into ReviewFormOptions set fieldName='grammar', level=3, description='Average';
insert into ReviewFormOptions set fieldName='grammar', level=4, description='Good';
insert into ReviewFormOptions set fieldName='grammar', level=5, description='Excellent';

insert into ReviewFormOptions set fieldName='suitableForShort', level=1, description='Not suitable';
insert into ReviewFormOptions set fieldName='suitableForShort', level=2, description='Can\'t tell';
insert into ReviewFormOptions set fieldName='suitableForShort', level=3, description='Suitable';

insert into ReviewFormOptions set fieldName='outcome', level=0, description='Unspecified';
insert into ReviewFormOptions set fieldName='outcome', level=-1, description='Rejected';
insert into ReviewFormOptions set fieldName='outcome', level=1, description='Accepted as short paper';
insert into ReviewFormOptions set fieldName='outcome', level=2, description='Accepted';

delete from ImportantDates where name='reviewFormUpdate';
insert into ImportantDates set name='reviewFormUpdate', start=current_timestamp;


drop table if exists PaperList;
create table PaperList (
  paperListId int(11) NOT NULL auto_increment,
  paperListName varchar(20) NOT NULL,
  description varchar(80) NOT NULL default '',
  sortCol int,
  PRIMARY KEY (paperListId),
  UNIQUE KEY paperListId (paperListId),
  KEY paperListName (paperListName)
) TYPE=MyISAM;

drop table if exists PaperFields;
create table PaperFields (
  fieldId int(11) NOT NULL,
  fieldName varchar(20),
  description varchar(80),
  sortable tinyint(1) default '1',
  display tinyint(1) default '1',
  PRIMARY KEY (fieldId),
  UNIQUE KEY fieldId (fieldId)
) TYPE=MyISAM;

drop table if exists PaperListColumns;
create table PaperListColumns (
  paperListId int(11) NOT NULL,
  fieldId int(11) NOT NULL,
  col int(3) NOT NULL,
  UNIQUE KEY paperListCol (paperListId,col)
) TYPE=MyISAM;

insert into PaperFields set fieldId=1, fieldName='id', description='ID';
insert into PaperFields set fieldId=2, fieldName='id', description='ID (manage link)';
insert into PaperFields set fieldId=3, fieldName='id', description='ID (review link)';
insert into PaperFields set fieldId=11, fieldName='title', description='Title';
insert into PaperFields set fieldId=12, fieldName='title', description='Title (manage link)';
insert into PaperFields set fieldId=13, fieldName='title', description='Title (review link)';
insert into PaperFields set fieldId=27, fieldName='status', description='Status';
insert into PaperFields set fieldId=28, fieldName='download', description='Download', sortable=0;
insert into PaperFields set fieldId=29, fieldName='reviewer', description='Reviewer type';
insert into PaperFields set fieldId=30, fieldName='reviewerStatus', description='Reviewer status';
insert into PaperFields set fieldId=31, fieldName='selector', description='Selector';
insert into PaperFields set fieldId=32, fieldName='review', description='Review';
insert into PaperFields set fieldId=33, fieldName='status', description='Status (for reviewers)';
insert into PaperFields set fieldId=34, fieldName='reviewerName', description='Reviewer name';
insert into PaperFields set fieldId=35, fieldName='reviewAssignment', description='Review assignment';
insert into PaperFields set fieldId=36, fieldName='topicMatch', description='Topic interest score';
insert into PaperFields set fieldId=37, fieldName='topicNames', description='Topic names', sortable=0, display=2;
insert into PaperFields set fieldId=38, fieldName='reviewerNames', description='Reviewer names', sortable=0, display=2;
insert into PaperFields set fieldId=39, fieldName='reviewPreference', description='Review preference';
insert into PaperFields set fieldId=40, fieldName='editReviewPreference', description='Edit review preference';
insert into PaperFields set fieldId=41, fieldName='reviewsStatus', description='Review counts';
insert into PaperFields set fieldId=42, fieldName='matches', description='Matches', display=0;
insert into PaperFields set fieldId=43, fieldName='desirability', description='Desirability';
insert into PaperFields set fieldId=44, fieldName='allPreferences', description='Reviewer preferences', sortable=0, display=2;
insert into PaperFields set fieldId=45, fieldName='reviewerTypeIcon', description='Reviewer type';
insert into PaperFields set fieldId=46, fieldName='optOverallMeritIcon', description='Overall merit (icon)';
insert into PaperFields set fieldId=47, fieldName='authorsMatch', description='Authors match', sortable=0, display=2;
insert into PaperFields set fieldId=48, fieldName='collaboratorsMatch', description='Collaborators match', sortable=0, display=2;

insert into PaperList set paperListId=1, paperListName='a',
	description='Authored papers', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(1, 2, 0), (1, 12, 1), (1, 27, 2);

insert into PaperList set paperListId=2, paperListName='s',
	description='Submitted papers', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(2, 31, 0), (2, 1, 1), (2, 11, 2), (2, 45, 3), (2, 41, 4),
	(2, 33, 5), (2, 46, 6);

insert into PaperList set paperListId=3, paperListName='all',
	description='All papers', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(3, 31, 0), (3, 1, 1), (3, 11, 2), (3, 27, 3), (3, 45, 4);

insert into PaperList set paperListId=4, paperListName='authorHome',
	description='My papers (homepage view)', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(4, 2, 0), (4, 12, 1), (4, 27, 2);

insert into PaperList set paperListId=6, paperListName='reviewerHome',
	description='Papers to review (homepage view)', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(6, 3, 0), (6, 13, 1), (6, 45, 2), (6, 33, 3);

insert into PaperList set paperListId=7, paperListName='r',
	description='Papers to review', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(7, 31, 0), (7, 3, 1), (7, 13, 2), (7, 45, 3), (7, 41, 4),
	(7, 33, 5);

insert into PaperList set paperListId=8, paperListName='reviewAssignment',
	description='Review assignments', sortCol=3;
insert into PaperListColumns (paperListId, fieldId, col) values
	(8, 3, 0), (8, 13, 1), (8, 39, 2), (8, 36, 3), (8, 43, 4), 
	(8, 35, 5), (8, 37, 6), (8, 38, 7), (8, 44, 8), (8, 46, 9),
	(8, 47, 10), (8, 48, 11);

insert into PaperList set paperListId=9, paperListName='editReviewPreference',
	description='Edit reviewer preferences', sortCol=3;
insert into PaperListColumns (paperListId, fieldId, col) values
	(9, 1, 0), (9, 11, 1), (9, 36, 2), (9, 45, 3), (9, 40, 4), 
	(9, 37, 5);

insert into PaperList set paperListId=12, paperListName='req',
	description='Papers to review', sortCol=0;
insert into PaperListColumns (paperListId, fieldId, col) values
	(12, 31, 0), (12, 3, 1), (12, 13, 2), (12, 45, 3), (12, 41, 4),
	(12, 33, 5);

delete from ImportantDates where name='paperListUpdate';
insert into ImportantDates set name='paperListUpdate', start=current_timestamp;
