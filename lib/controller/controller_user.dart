import 'package:spotilike_front/class/api_params.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spotilike_front/class/user.dart';

class ControllerUser {
 static  Future<User?> getUser(int userID) async {
    final apiBase = ApiParams.apiBaseUrl;
    final headers = await ApiParams.obterHeaders();
    final response = await http.get(
      Uri.parse('$apiBase/api/users/$userID/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      return null;
    }
  }
 static  Future<User?> loginUser(String email, String password) async{
  try {
    final apiBase = ApiParams.apiBaseUrl;
    final headers = await ApiParams.obterHeaders();
    final response = await  http.post(
      Uri.parse('$apiBase/api/users/login/'),
      headers: headers,
      body: jsonEncode({
        'username': email,
        'password': password,
      }),);
             
      if(response.statusCode == 200){
        final jsonResponse = jsonDecode(response.body);
        final iduser = jsonResponse['id'];
        final userReq = getUser(iduser);
        return userReq;
      }else{
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  
    static Future<bool> registerUser(String name, String email, String password) async {
      try{
        final apiBase = ApiParams.apiBaseUrl;
        final response = await http.post(
          Uri.parse('$apiBase/api/users/register/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'senha': password,
          }),
        );
        
        if(response.statusCode == 201){
          return true;
        }else{
          return false;
        }
        }catch(e){
          return false;
        }
    }
  }