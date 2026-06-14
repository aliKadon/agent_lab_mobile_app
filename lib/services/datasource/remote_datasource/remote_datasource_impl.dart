import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agent_lab/services/datasource/remote_datasource/remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pusher_client/pusher_client.dart';

import '../../../models/all_agents_list_model.dart';
import '../../../models/chat_model.dart';
import '../../../models/create_agents/answer_and_create_model.dart';
import '../../../models/create_agents/pick_a_model.dart';
import '../../../models/delete_agent_by_id_model.dart';
import '../../../models/get_active_agents_in_chat_model.dart';
import '../../../models/get_agnts_details_with_code_source_model.dart';
import '../../../models/remove_agents_from_chat_model.dart';
import '../../../models/rescan_disk_and_update_the_database_model.dart';
import '../../../models/search_progress_event.dart';
import '../../../models/upload_file_model.dart';
import '../../../utils/constants/config.dart';
import '../../../utils/constants/constants.dart';
import '../../api_constants.dart';
import '../../error/failure.dart';

class RemoteDataSourceImp extends RemoteDataSource {
  final Dio _dio;
  final Logger _log;
  final BaseUrl _baseUrl;
  bool endReceived = false;
  Timer? endTimer;

  RemoteDataSourceImp({required Dio dio, required Logger log, required BaseUrl baseUrl})
      : _dio = dio,
        _log = log,
        _baseUrl = baseUrl;

  void handleResponse(Response<dynamic> response, String? msg) {
    if (response.statusCode == 500) {
      throw const ServerFailure('Internal server error');
    }
    showGenericError(response.requestOptions.path, response.statusCode, msg);
  }

  void showGenericError(url, statusCode, message) {
    var path = url.split('?')[0];
    switch (statusCode) {
      case 400:
        throw BadRequestFailure(message ?? 'Bad request failure');
      case 401:
        // if (path == _baseUrl.auth.login) {
        //   throw const UserDoesNotExistFailure('');
        // }
        throw UnauthorizedFailure(message ?? 'Unauthorized failure');
      case 403:
        throw ForbiddenFailure(message);
      case 404:
        throw NotFoundFailure(message ?? "Not found failure");
      case 406:
        throw const BadRequestFailure('Bad request failure');
      case 408:
        throw const OTPExpiredFailure('Expired failure');
      case 409:
        throw InsufficientCreditsFailure(message ?? 'Oops! Looks like there’s a little conflict. Try again in a bit.');
      case 413:
        throw const FileSizeGreaterFailure('File Sized Exceed!');
      case 423:
        throw const LimitExceedFailure('Limit exceed failure');
      case 429:
        throw const TemporarilyBlockedFailure('you_are_blocked_temporarily');
      case 500:
        throw const InternalServerErrorFailure('internal_server_error_failure');
      case 501:
        throw const NotImplementedFailure('not_implement_failure');
      default:
        throw const InternalServerErrorFailure('internal_server_error_failure');
    }
  }

  @override
  Stream<SearchProgressEvent> fetchChatStream({required String description}) async* {
    final controller = StreamController<SearchProgressEvent>();
    final buffer = StringBuffer();

    try {
      final response = await _dio.post<ResponseBody>(
        'https://agent-generated-api.onrender.com/agents/generate/start/stream',
        data: jsonEncode({'description': description}),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
        ),
      );

      response.data!.stream.cast<List<int>>().transform(utf8.decoder).listen(
            (chunk) {
          buffer.write(chunk);
          String content = buffer.toString();

          // SSE events are separated by \n\n
          while (content.contains('\n\n')) {
            final idx = content.indexOf('\n\n');
            final block = content.substring(0, idx);
            content = content.substring(idx + 2);
            buffer.clear();
            buffer.write(content);

            for (final line in block.split('\n')) {
              if (!line.startsWith('data: ')) continue;
              final jsonStr = line.substring(6).trim();
              try {
                final json = jsonDecode(jsonStr) as Map<String, dynamic>;
                final event = SearchProgressEvent.fromJson(json);
                if (!controller.isClosed) controller.add(event);
                if (event.status == 'done' || event.status == 'error') {
                  controller.close();
                }
              } catch (e) {
                debugPrint('SSE parse error: $e');
              }
            }
          }
        },
        onError: (e) {
          controller.addError(e);
          controller.close();
        },
        onDone: () {
          if (!controller.isClosed) controller.close();
        },
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        controller.addError(errorData['message'] ?? errorData);
      } else {
        controller.addError(e);
      }
      controller.close();
    } catch (e) {
      debugPrint('SSE stream error: $e');
      controller.addError(e);
      controller.close();
    }

    controller.onCancel = () {
      debugPrint('SSE stream cancelled => cleaning up');
      if (!controller.isClosed) controller.close();
    };

    yield* controller.stream;
  }

  @override
  Future<PickAModel> pickAModelFun({required PickAModelBody body}) async{
    var api = _baseUrl.homePage.pickModel;
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.post(api,data: jsonEncode(body));

      final data = response.data;

      debugPrint('[remote data source : post pick model] $response');
      return PickAModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : post pick model] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : post pick model] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<AnswerAndCreateModel> createAndAnswer({required AnswerAndCreateModelBody body}) async{
    var api = _baseUrl.homePage.answerAndCreate;
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.post(api,data: jsonEncode(body));

      final data = response.data;

      debugPrint('[remote data source : post AnswerAndCreateModel] $response');
      return AnswerAndCreateModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint(' [dioError : post AnswerAndCreateModel] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : post AnswerAndCreateModel] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<AllAgentsList> getAllAgents() async{
    var api = _baseUrl.homePage.getAllAgents;
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.get(api);

      final data = response.data;

      debugPrint('[remote data source : get all agents] $response');
      return AllAgentsList.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : get all agents] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : get all agents] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<GetAgentsDetailsWithCodeSource> getAgentDetails({required String agentId}) async{
    var api = _baseUrl.homePage.getAgentDetails(agentId: agentId);
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.get(api);

      final data = response.data;

      debugPrint('[remote data source : get agent details] $response');
      return GetAgentsDetailsWithCodeSource.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : get agent details] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : get agent details] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<RescanDiskAndUpdateTheDatabaseModel> syncAgentWithDatabase() async {
    var api = _baseUrl.homePage.agentSync;
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.get(api);

      final data = response.data;

      debugPrint('[remote data source : agent sync] $response');
      return RescanDiskAndUpdateTheDatabaseModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : agent sync] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : agent sync] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<ChatModel> getChat({required ChatBody body}) async{
    var api = _baseUrl.homePage.chat;
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.post(api, data: jsonEncode(body));

      final data = response.data;

      debugPrint('[remote data source : get chat] $response');
      return ChatModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : get chat] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : get chat] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<DeleteAgentByIdModel> deleteAgent({required String agentId}) async{
    var api = _baseUrl.homePage.deleteAgent(agentId: agentId);
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.delete(api);

      final data = response.data;

      debugPrint('[remote data source : delete agent] $response');
      return DeleteAgentByIdModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : delete agent] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : delete agent] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<List<GetActiveAgentsInChatModel>> getChatAgents() async{
    var api = _baseUrl.homePage.getChatAgents;
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.delete(api);

      final data = response.data;

      debugPrint('[remote data source : get chat agents] $response');
      return List<GetActiveAgentsInChatModel>.from(data.map((x) => GetActiveAgentsInChatModel.fromJson(x)));
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : get chat agents] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : get chat agents] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<AddRemoveAgentsFromChatModel> deleteAgentFromChat({required String agentName}) async{
    var api = _baseUrl.homePage.deleteAddAgentFromChat(agentName: agentName);
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.delete(api);

      final data = response.data;

      debugPrint('[remote data source : delete agent from chat] $response');
      return AddRemoveAgentsFromChatModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : delete agent from chat] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : delete agent from chat] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<AddRemoveAgentsFromChatModel> addAgentFromChat({required String agentName}) async{
    var api = _baseUrl.homePage.deleteAddAgentFromChat(agentName: agentName);
    _dio.options.headers = {'accept': 'application/json'};
    try {
      final response = await _dio.post(api);

      final data = response.data;

      debugPrint('[remote data source : add agent from chat] $response');
      return AddRemoveAgentsFromChatModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : add agent from chat] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : add agent from chat] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }


  @override
  Future<UploadFilesModel> uploadFile({required File file}) async{
    var api = _baseUrl.homePage.uploadFile;
    _dio.options.headers = {'accept': 'application/json'};

    debugPrint(api);
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      final response = await _dio.post(api, data: formData);

      final data = response.data;

      debugPrint('[remote data source : uploadMedia] $response');

      return UploadFilesModel.fromJson(data);
    } on DioException catch (dioError) {
      if (dioError.response == null) {
        throw Constants.somethingWentWrong;
      }
      debugPrint('[dioError : uploadMedia] ${dioError.response!}');
      handleResponse(dioError.response!, dioError.response!.data['message']);
    } catch (error) {
      debugPrint('[error : uploadMedia] $error');
      throw Constants.somethingWentWrong;
    }
    throw Constants.somethingWentWrong;
  }

}
