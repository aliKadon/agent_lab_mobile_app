//! yes no enum
enum YesNoEnum { yes, no }

//! language enum
enum LanguageEnum { en, ar }

//! theme enum
enum ThemeEnum { light, dark }

//! login enum
enum LoginEnum { google, apple }

//! attachement type enum
enum AttachementType { image, file }

//! file type enums
enum FileTypeEnum { docx, doc, pdf, epub, txt, ppt, pptx, xls, xlsx, csv, png, jpg, jpeg, heif, heic, m4a, mp3, wav, mp4 }

enum FeedType { document, audio, image, text }

//! group type enum
enum GroupTypeEnum { trendingGroup, myGroup }

//! group invitation status enum
enum GroupInvitationStatus { accepted, rejected }

//! group message type enum
enum GroupMessageTypeEnum { text, image, document, media }

//! knowledge file type enum
enum KnowledgeFileTypeEnum { document, audio, video, image }

//! profile tabs enum
enum ProfileTabsEnum { posts, docs, audios }

//! search tabs enum
enum SearchTabsEnum { feed, user, group }

//! feed/post enum
enum FeedPostEnum { feed, post }

//! post action enum
enum PostActionEnum { comment, like, views, aichat, download}

//! single player quiz type enum
enum SinglePlayerQuizTypeEnum { mcqs , fillInBlanks , shortAnswer, flashCards}

//! agent creation flow step enum
enum AgentCreationStep { idle, streaming, modelSelection, pickingModel, answering, toolSelection, creating, done, error }

//! chat attachment type enum
enum ChatAttachmentType { image, document, audio }
