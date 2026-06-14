
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../models/all_agents_list_model.dart';
import '../../models/chat_model.dart';
import '../../models/create_agents/answer_and_create_model.dart';
import '../../models/create_agents/pick_a_model.dart';
import '../../models/delete_agent_by_id_model.dart';
import '../../models/get_active_agents_in_chat_model.dart';
import '../../models/get_agnts_details_with_code_source_model.dart';
import '../../models/remove_agents_from_chat_model.dart';
import '../../models/rescan_disk_and_update_the_database_model.dart';
import '../../models/search_progress_event.dart';
import '../../models/upload_file_model.dart';
import '../error/failure.dart';

abstract class Repository {

  // This method for stream chat
  // Input: []
  // Output: [stream of strings]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, Stream<SearchProgressEvent>>> fetchChatStream({required String description});


  // This method will get PickAModel
  // Input: [PickAModelBody]
  // Output: [PickAModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, PickAModel>> getMessagesFromSession({required PickAModelBody body});

  // This method will get AnswerAndCreateModel
  // Input: [AnswerAndCreateModelBody]
  // Output: [AnswerAndCreateModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, AnswerAndCreateModel>> createAndAnswer({required AnswerAndCreateModelBody body});

  // This method will get all agents
  // Input: []
  // Output: [AllAgentsList]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, AllAgentsList>> getAllAgents();


  // This method will get agents details
  // Input: []
  // Output: [AllAgentsList]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, GetAgentsDetailsWithCodeSource>> getAgentDetails({required String agentId});


  // This method will sync agent with database
  // Input: []
  // Output: [RescanDiskAndUpdateTheDatabaseModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, RescanDiskAndUpdateTheDatabaseModel>> syncAgentWithDatabase();


  // This method will get chat
  // Input: []
  // Output: [ChatModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, ChatModel>> getChat({required ChatBody body});


  // This method will get chat
  // Input: []
  // Output: [DeleteAgentByIdModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, DeleteAgentByIdModel>> deleteAgent({required String agentId});


  // This method will get chat agents
  // Input: []
  // Output: [GetActiveAgentsInChatModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, List<GetActiveAgentsInChatModel>>> getChatAgents();


  // This method will delete agent from chat
  // Input: []
  // Output: [AddRemoveAgentsFromChatModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, AddRemoveAgentsFromChatModel>> deleteAgentFromChat({required String agentName});


  // This method will add agent from chat
  // Input: []
  // Output: [AddRemoveAgentsFromChatModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, AddRemoveAgentsFromChatModel>> addAgentFromChat({required String agentName});


  // This method will upload file
  // Input: []
  // Output: [UploadFilesModel]
  // if unsuccessful the response will be [Failure]
  Future<Either<Failure, UploadFilesModel>> uploadFile({required File file});
}
