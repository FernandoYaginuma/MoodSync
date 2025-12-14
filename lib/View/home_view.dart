import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/Controller/home_controller.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/View/patient_profile_view.dart';
import 'package:android2/View/patient_mural_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = HomeController.instance;
  DateTime _focusedDay = DateTime.now();

  bool _checouVinculacoes = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    controller.carregarDadosUsuario();

    // ✅ Checa vínculos pendentes APÓS a tela renderizar (diálogo aparece na Home, não no Login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _checouVinculacoes) return;
      _checouVinculacoes = true;
      _verificarVinculacoesPendentes();
    });
  }

  Future<void> _verificarVinculacoesPendentes() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final pacienteId = user?.uid;

    if (!mounted || email == null || pacienteId == null) return;

    final snap = await _firestore
        .collection('vinculacoes')
        .where('pacienteEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pendente')
        .get();

    for (final doc in snap.docs) {
      if (!mounted) return;

      final data = doc.data();
      final profissionalNome = data['profissionalNome'] ?? 'Profissional';
      final profissionalId = data['profissionalId'];

      if (profissionalId == null) continue;

      final aceitar = await _mostrarDialogConsentimento(
        context,
        profissionalNome,
      );

      // se por algum motivo voltou null, para o fluxo
      if (!mounted || aceitar == null) return;

      if (aceitar) {
        await _aceitarVinculacao(doc.id, profissionalId, pacienteId);
      } else {
        await _recusarVinculacao(doc.id);
      }
    }
  }

  Future<bool?> _mostrarDialogConsentimento(
    BuildContext context,
    String profissionalNome,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Solicitação de vínculo"),
        content: Text("$profissionalNome deseja se vincular a você."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Recusar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Aceitar"),
          ),
        ],
      ),
    );
  }

  Future<void> _aceitarVinculacao(
    String docId,
    String profissionalId,
    String pacienteId,
  ) async {
    // atualiza status da solicitação
    await _firestore.collection('vinculacoes').doc(docId).update({
      'status': 'aceito',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // profissional → pacientes
    await _firestore
        .collection('profissional_pacientes')
        .doc(profissionalId)
        .set({
      'pacientes': FieldValue.arrayUnion([pacienteId])
    }, SetOptions(merge: true));

    // paciente → profissionais
    await _firestore
        .collection('paciente_profissionais')
        .doc(pacienteId)
        .set({
      'profissionais': FieldValue.arrayUnion([profissionalId])
    }, SetOptions(merge: true));

    // users
    await _firestore.collection('users').doc(pacienteId).set({
      'profissionaisVinculados': FieldValue.arrayUnion([profissionalId]),
    }, SetOptions(merge: true));
  }

  Future<void> _recusarVinculacao(String docId) async {
    await _firestore.collection('vinculacoes').doc(docId).update({
      'status': 'recusado',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.blueLogo,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => controller.logout(context),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientProfileView(),
                  ),
                ).then((_) {
                  controller.carregarDadosUsuario();
                  setState(() {});
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.25),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
            const Spacer(),
            const Text(
              "MoodSync",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blueLogo.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.blueLogo.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.blueLogo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: controller.nomeUsuario,
                    builder: (context, nome, _) {
                      return Text(
                        'Olá, $nome!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackBackground,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 6),
                  Text(
                    'Como você está hoje?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.week,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.blueLogo,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        Navigator.pushNamed(
                          context,
                          '/calendar',
                          arguments: selectedDay,
                        );
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.forum_outlined, size: 20),
                      label: const Text(
                        "Mensagens do Profissional",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLogo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientMuralView(
                              pacienteId: controller.userId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Registros Recentes:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackBackground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: StreamBuilder<Map<String, DayModel>>(
                      stream: controller.getRegistrosStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Erro ao carregar registros."),
                          );
                        }

                        final data = snapshot.data ?? {};
                        final diasOrdenados = data.values.toList()
                          ..sort((a, b) => b.date.compareTo(a.date));

                        if (diasOrdenados.isEmpty) {
                          return const Center(
                            child: Text('Nenhum registro encontrado.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: diasOrdenados.length,
                          itemBuilder: (context, index) {
                            final day = diasOrdenados[index];
                            final formattedDate =
                                "${day.date.day.toString().padLeft(2, '0')}/${day.date.month.toString().padLeft(2, '0')}/${day.date.year}";

                            final emotionsText = day.emotions.isEmpty
                                ? 'Sem sentimentos'
                                : day.emotions.join(', ');

                            return Card(
                              color: Colors.white.withOpacity(0.95),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.sentiment_satisfied_alt_outlined,
                                  color: AppColors.blueLogo,
                                ),
                                title: Text(emotionsText),
                                subtitle: Text(
                                  day.note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(formattedDate),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
