import 'package:flutter/foundation.dart';


class BaseUrl {
  String hostUrlDev;
  String hostUrl;

  BaseUrl({
    required this.hostUrlDev,
    required this.hostUrl,
  });

  HomePage get homePage => HomePage(hostUrl, hostUrlDev);

  Auth get auth => Auth(hostUrl, hostUrlDev);

  Groups get groups => Groups(hostUrl, hostUrlDev);

  Chat get chat => Chat(hostUrl, hostUrlDev);
  Profile get profile => Profile(hostUrl, hostUrlDev);
  Quiz get quiz => Quiz(hostUrl, hostUrlDev);
  DM get dm => DM(hostUrl, hostUrlDev);
}

class HomePage {
  String hostUrl;
  String hostUrlDev;

  HomePage(this.hostUrl, this.hostUrlDev);

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      return hostUrlDev;
    }
  }





  String getAgentDetails({required String agentId}) {
    return "${baseUrl}agents/$agentId";
  }

  String deleteAgent({required String agentId}) {
    return "${baseUrl}agents/$agentId";
  }


  String deleteAddAgentFromChat({required String agentName}) {
    return "${baseUrl}chat/agents/$agentName";
  }

  String get pickModel => "${baseUrl}agents/generate/continue";
  String get answerAndCreate => "${baseUrl}agents/generate/continue";
  String get getAllAgents => "${baseUrl}agents";
  String get agentSync => "${baseUrl}agents/sync";
  String get chat => "${baseUrl}chat";
  String get getChatAgents => "${baseUrl}chat/agents";
  String get uploadFile => "${baseUrl}files/upload";






}

class Auth {
  String hostUrl;
  String hostUrlDev;

  Auth(this.hostUrl, this.hostUrlDev);

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      return hostUrlDev;
    }
  }

  String get googleLogin => "${baseUrl}user/auth/oauth/google/authorize";

  String get appleLogin => "${baseUrl}user/auth/oauth/apple/authorize";

  String get generateAuthToken => "${baseUrl}user/api/account/generate_auth_token";
}

class Profile {
  String hostUrl;
  String hostUrlDev;

  Profile(this.hostUrl, this.hostUrlDev);

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      return hostUrlDev;
    }
  }

  String get profile => "${baseUrl}user/api/account/profile";

  String get updateUsername => "${baseUrl}user/api/account/set_username";

  String userProfile({required String userId}) {
    return "${baseUrl}social/api/profile/$userId";
  }

  String getUsers({required String query}) {
    return "${baseUrl}social/api/profile/search?username=$query";
  }

  String followUser({required String userId}) {
    return "${baseUrl}social/api/profile/$userId/follow_user";
  }

  String unfollowUser({required String userId}) {
    return "${baseUrl}social/api/profile/$userId/unfollow_user";
  }



  String get transferCredit => "${baseUrl}user/api/account/credit/transfer";

  String get authorizeLoginToken => "${baseUrl}user/api/account/authorize_login_token";

  String get referral => "${baseUrl}user/api/account/referral";

  String ambassodorContent({required String keyName}) => "${baseUrl}user/api/account/configuration?keyname=${keyName}";
}

class Groups {
  String hostUrl;
  String hostUrlDev;

  Groups(
    this.hostUrl,
    this.hostUrlDev,
  );

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      // return hostUrlDev;
      return hostUrlDev;
    }
  }



  String get groupCats => "${baseUrl}social/api/group/categories";

  String get createGroup => "${baseUrl}social/api/group";

  String updateGroup({required String id}) {
    return "${baseUrl}social/api/group/$id";
  }

  String groupInfo({required String id}) {
    return "${baseUrl}social/api/group/$id/info";
  }

  String groupInfoByInviteCode({required String inviteCode}) {
    return "${baseUrl}social/api/group/info/$inviteCode";
  }

  String exitGroup({required String id}) {
    return "${baseUrl}social/api/group/$id/exit";
  }

  String updateLastMessageSeen({required String groupId}) {
    return "${baseUrl}social/api/group/$groupId/last_message_seen";
  }


  String sendGroupJoinRequests({required String groupId}) {
    return "${baseUrl}social/api/group/$groupId/join_request";
  }

  String get invitesCount => "${baseUrl}social/api/group/invites_and_requests_count";


}

class Chat {
  String hostUrl;
  String hostUrlDev;

  Chat(this.hostUrl, this.hostUrlDev);

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      return hostUrlDev;
    }
  }

  String get createSession => "${baseUrl}andy/api/chat/v3/sessions";

  String getSessions({String? key}) {
    return "${baseUrl}andy/api/chat/sessions?key=$key&limit=17";
  }

  String sendMsg({String? sessionId}) {
    return "${baseUrl}andy/api/chat/v3/sessions/$sessionId/query";
  }

  String getMessagesFromSession({String? sessionId,String? key}) {
    return "${baseUrl}andy/api/chat/$sessionId/messages?limit=5&key=$key";
  }

  String getMessagesById({String? sessionId, String? messageId}) {
    return "${baseUrl}andy/api/chat/$sessionId/message/$messageId";
  }

  String get createDocument => "${baseUrl}media/api/v3/account/media/ingest/session";

  String get webExtractor => "${baseUrl}media/api/account/webpage/extractor";

  String renameDoc({String? docId}) {
    return "${baseUrl}media/api/v3/account/media/$docId";
  }

  String summarize({String? docId}) {
    return "${baseUrl}media/api/v3/account/media/execute/$docId";
  }

  String get textToSpeech => "${baseUrl}media/api/account/audio/generate/speech";
  String get textToDoc => "${baseUrl}user/api/account/tools/text_to_docx";

  String getKnowledgeFile({String? type, String? docType}) {
    return "${baseUrl}media/api/account/document?page=1&limit=100&sort=-createdAt&media_type=$type&doc_type=$docType";
  }

  String deleteKnowledgeFile({String? docId}) {
    return "${baseUrl}media/api/account/document/$docId";
  }
}

class Quiz {
  String hostUrl;
  String hostUrlDev;

  Quiz(this.hostUrl, this.hostUrlDev);

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      return hostUrlDev;
    }
  }

  String get submitQuiz => "${baseUrl}media/api/account/quiz/submissions";


  String get createRoom => "${baseUrl}game/api/game";

  String get submitShortAnswer => "${baseUrl}media/api/admin/account/answers/evaluate";

  String getAllSinglePlayerQuiz({num? page}) {
    return "${baseUrl}media/api/account/quiz/submissions?page=$page&sort=-updatedAt&limit=20";
  }

  String getJoinedGame({num? page}) {
    return "${baseUrl}game/api/game/joined?page=$page&limit=20";
  }

  String generateQuiz({String? documentId}) {
    return "${baseUrl}media/api/v3/account/media/execute/$documentId";
  }

  String getAllFlashcards({String? userId}) {
    return "${baseUrl}user/api/account/user/flashcards/$userId";
  }

  String joinedGame({String? inviteCode}) {
    return "${baseUrl}game/api/game/info/$inviteCode";
  }

  String join({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId/join";
  }

  String gameInfo({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId/info";
  }

  String gameMembers({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId/members?limit=50";
  }

  String chatMessage({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId/message";
  }

  String getRoomMessage({String? gameId, String lastMessageId = ""}) {
    return "${baseUrl}game/api/game/$gameId/messages?key=$lastMessageId&limit=20";
  }

  String deleteRoom({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId";
  }

  String startGame({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId/start";
  }

  String gameSubmission({String? gameId}) {
    return "${baseUrl}game/api/game/$gameId/submissions";
  }

  String leaderBoard({String? gameId, num? page}) {
    return "${baseUrl}game/api/game/$gameId/leaderboard?page=$page&limit=20";
  }

  String leaderBoardByUserId({String? gameId, String? userId}) {
    return "${baseUrl}game/api/game/$gameId/leaderboard?page=1&user_id=$userId&limit=10";
  }
}

class DM {
  String hostUrl;
  String hostUrlDev;

  DM(this.hostUrl, this.hostUrlDev);

  String get baseUrl {
    if (kReleaseMode) {
      // Production
      return hostUrl;
    } else {
      // Dev
      return hostUrlDev;
    }
  }

  String get sendDM => "${baseUrl}social/api/dm/message";
}
