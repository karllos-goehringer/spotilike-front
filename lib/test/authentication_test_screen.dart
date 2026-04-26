import 'package:flutter/material.dart';
import '../class/api_params.dart';
import '../class/localStorage.dart';

/// Tela de Teste de Autenticação
/// 
/// Widget para testar a autenticação de forma visual e interativa
/// Use em main.dart durante o desenvolvimento:
/// 
/// void main() {
///   runApp(const MaterialApp(home: AuthenticationTestScreen()));
/// }

class AuthenticationTestScreen extends StatefulWidget {
  const AuthenticationTestScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationTestScreen> createState() =>
      _AuthenticationTestScreenState();
}

class _AuthenticationTestScreenState extends State<AuthenticationTestScreen> {
  String _statusMessage = 'Aguardando ação...';
  String _tokenDisplay = 'Nenhum token carregado';
  bool _isLoading = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentToken();
  }

  Future<void> _checkCurrentToken() async {
    final token = await ApiParams.obterToken();
    setState(() {
      if (token != null) {
        _isAuthenticated = true;
        _tokenDisplay = 'Token: ${token.substring(0, 30)}...';
        _statusMessage = '✅ Token encontrado no armazenamento';
      } else {
        _statusMessage = '⚠️ Nenhum token encontrado';
        _tokenDisplay = 'Nenhum token carregado';
      }
    });
  }

  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '⏳ Autenticando...';
    });

    try {
      final token = await ApiParams.autenticarAPI();

      if (token != null) {
        setState(() {
          _isLoading = false;
          _isAuthenticated = true;
          _tokenDisplay = 'Token: ${token.substring(0, 30)}...';
          _statusMessage = '✅ Autenticação bem-sucedida!';
        });
      } else {
        setState(() {
          _isLoading = false;
          _isAuthenticated = false;
          _statusMessage = '❌ Falha na autenticação';
          _tokenDisplay = 'Erro ao obter token';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isAuthenticated = false;
        _statusMessage = '❌ Erro: $e';
        _tokenDisplay = 'Erro';
      });
    }
  }

  Future<void> _testLogout() async {
    try {
      await ApiParams.limparToken();
      setState(() {
        _isAuthenticated = false;
        _tokenDisplay = 'Nenhum token carregado';
        _statusMessage = '✅ Logout realizado com sucesso!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erro ao fazer logout: $e';
      });
    }
  }

  Future<void> _testHeaders() async {
    try {
      final headers = await ApiParams.obterHeaders();
      String headerText = '';
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          headerText += '$key: ${value.substring(0, 30)}...\n';
        } else {
          headerText += '$key: $value\n';
        }
      });

      _showDialog('Headers Gerados', headerText);
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Erro ao gerar headers: $e';
      });
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Teste de Autenticação'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configurações
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configurações',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildConfigRow('Base URL:', ApiParams.apiBaseUrl),
                    _buildConfigRow('Usuário:', ApiParams.apiUser),
                    _buildConfigRow('Endpoint:', ApiParams.loginEndpoint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status
            Card(
              color: _isAuthenticated
                  ? Colors.green[50]
                  : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isAuthenticated
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: _isAuthenticated
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_statusMessage),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _tokenDisplay,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botões de Teste
            const Text(
              'Testes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              label: '🔑 Autenticar',
              onPressed: _isLoading ? null : _testAuthentication,
              color: Colors.blue,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              label: '📋 Ver Headers',
              onPressed: _isLoading ? null : _testHeaders,
              color: Colors.orange,
              isLoading: false,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              label: '🔄 Recarregar Token',
              onPressed: _isLoading ? null : _checkCurrentToken,
              color: Colors.purple,
              isLoading: false,
            ),
            const SizedBox(height: 8),
            _buildTestButton(
              label: '🚪 Logout',
              onPressed: _isLoading ? null : _testLogout,
              color: Colors.red,
              isLoading: false,
            ),
            const SizedBox(height: 20),

            // Informações
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ℹ️ Informações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• O token é automaticamente armazenado em SharedPreferences\n'
                      '• O token é incluído em todos os headers das requisições\n'
                      '• O formato é: Authorization: Bearer [token]\n'
                      '• Ao fazer logout, o token é removido do armazenamento',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
      ),
    );
  }
}
