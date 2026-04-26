import 'package:flutter/material.dart';
import '../class/api_params.dart';
import '../class/localStorage.dart';

/// Teste de Autenticação da API
/// 
/// Este arquivo contém testes para validar o fluxo de autenticação.
/// Execute no console com: dart lib/test/auth_test.dart

void main() async {
  print('═══════════════════════════════════════════');
  print('🔐 TESTE DE AUTENTICAÇÃO DA API');
  print('═══════════════════════════════════════════\n');

  // Teste 1: Verificar credenciais
  print('✓ Teste 1: Verificando credenciais configuradas');
  print('   Base URL: ${ApiParams.apiBaseUrl}');
  print('   Usuário: ${ApiParams.apiUser}');
  print('   Endpoint: ${ApiParams.loginEndpoint}\n');

  // Teste 2: Fazer login
  print('✓ Teste 2: Tentando autenticar...');
  final token = await ApiParams.autenticarAPI();

  if (token != null) {
    print('   ✅ Autenticação bem-sucedida!');
    print('   Token: ${token.substring(0, 20)}...\n');

    // Teste 3: Verificar se o token foi armazenado
    print('✓ Teste 3: Verificando armazenamento do token...');
    final storage = LocalStorage();
    final tokenArmazenado = await storage.getToken();

    if (tokenArmazenado != null) {
      print('   ✅ Token armazenado com sucesso!\n');

      // Teste 4: Verificar recuperação do token
      print('✓ Teste 4: Recuperando token armazenado...');
      final tokenRecuperado = await ApiParams.obterToken();
      if (tokenRecuperado != null) {
        print('   ✅ Token recuperado com sucesso!\n');

        // Teste 5: Verificar headers com autenticação
        print('✓ Teste 5: Verificando headers com autenticação...');
        final headers = await ApiParams.obterHeaders();
        print('   Headers gerados:');
        headers.forEach((key, value) {
          if (key == 'Authorization') {
            print('   ├─ $key: ${value.substring(0, 30)}...');
          } else {
            print('   ├─ $key: $value');
          }
        });
        print('');

        // Teste 6: Logout
        print('✓ Teste 6: Testando logout...');
        await ApiParams.limparToken();
        final tokenAposLogout = await storage.getToken();

        if (tokenAposLogout == null) {
          print('   ✅ Token removido com sucesso!\n');
        } else {
          print('   ❌ Erro: Token ainda existe após logout\n');
        }
      } else {
        print('   ❌ Erro ao recuperar token\n');
      }
    } else {
      print('   ❌ Erro: Token não foi armazenado\n');
    }
  } else {
    print('   ❌ Falha na autenticação!');
    print('   Verifique:');
    print('   1. Se a API está rodando em ${ApiParams.apiBaseUrl}');
    print('   2. Se as credenciais estão corretas');
    print('   3. Se o endpoint de login é ${ApiParams.loginEndpoint}\n');
  }

  print('═══════════════════════════════════════════');
  print('✅ TESTES CONCLUÍDOS');
  print('═══════════════════════════════════════════');
}
