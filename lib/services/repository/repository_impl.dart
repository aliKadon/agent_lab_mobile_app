import 'dart:io';

import 'package:agent_lab/services/repository/repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:logger/logger.dart';

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
import '../../utils/constants/constants.dart';
import '../datasource/local_datasource/local_datasource.dart';
import '../datasource/remote_datasource/remote_datasource.dart';
import '../error/failure.dart';

class RepositoryImpl implements Repository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  RepositoryImpl({required RemoteDataSource remoteDataSource, required LocalDataSource localDataSource, required Logger log})
    : _remoteDataSource = remoteDataSource,
      _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AddRemoveAgentsFromChatModel>> addAgentFromChat({required String agentName}) async {
    try {
      return Right(await _remoteDataSource.addAgentFromChat(agentName: agentName));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnswerAndCreateModel>> createAndAnswer({required AnswerAndCreateModelBody body}) async {
    try {
      return Right(await _remoteDataSource.createAndAnswer(body: body));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeleteAgentByIdModel>> deleteAgent({required String agentId}) async {
    try {
      return Right(await _remoteDataSource.deleteAgent(agentId: agentId));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddRemoveAgentsFromChatModel>> deleteAgentFromChat({required String agentName}) async {
    try {
      return Right(await _remoteDataSource.deleteAgentFromChat(agentName: agentName));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Stream<SearchProgressEvent>>> fetchChatStream({required String description}) async {
    try {
      return Right(_remoteDataSource.fetchChatStream(description: description));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetAgentsDetailsWithCodeSource>> getAgentDetails({required String agentId}) async {
    try {
      return Right(await _remoteDataSource.getAgentDetails(agentId: agentId));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AllAgentsList>> getAllAgents() async {
    try {
      return Right(await _remoteDataSource.getAllAgents());
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatModel>> getChat({required ChatBody body}) async {
    try {
      return Right(await _remoteDataSource.getChat(body: body));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GetActiveAgentsInChatModel>>> getChatAgents() async {
    try {
      return Right(await _remoteDataSource.getChatAgents());
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PickAModel>> getMessagesFromSession({required PickAModelBody body}) async {
    try {
      return Right(await _remoteDataSource.pickAModelFun(body: body));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RescanDiskAndUpdateTheDatabaseModel>> syncAgentWithDatabase() async {
    try {
      return Right(await _remoteDataSource.syncAgentWithDatabase());
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UploadFilesModel>> uploadFile({required File file}) async {
    try {
      return Right(await _remoteDataSource.uploadFile(file: file));
    } on Failure catch (e) {
      return Left(e);
    } on DioException catch (_) {
      return Left(ServerFailure(Constants.somethingWentWrong));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
