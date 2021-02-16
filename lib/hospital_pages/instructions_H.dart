import 'package:flutter/material.dart';

class InstructionsHPage extends StatefulWidget {
  @override
  _InstructionsHPageState createState() => _InstructionsHPageState();
}

class _InstructionsHPageState extends State<InstructionsHPage> {
  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruções'),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'AO INICIAR, VERIFIQUE SE ...',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'O Raspberry Pi se encontra ligado à corrente (luz vermelha ligada).',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                          'O(s) dispositivo(s) de aquisição se encontram ligados (luz branca a piscar devagar).',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                          'O(s) dispositivo(s) de aquisição se encontram bem posicionados no paciente.',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                          'O telemóvel se encontra conectado à rede "PreEpiSeizures". Caso contrário, conectar com a password "preepiseizures".',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'PASSO-A-PASSO',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              //height: 250.0,
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text('1. Fazer scan do código QR do paciente.',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '2. ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: 'Conectividade',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ': Conectar ao servidor e iniciar processo para aquisição.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '3. ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: 'Selecionar dispositivos',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ': Permite selecionar os dispositivos de aquisição default ou novos (por escrita ou código QR). Para selecionar apenas 1 dispositivo, deixe a outra entrada em branco. Caso queira guardar os novos dispositivos como default, pressione ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: '"Definir novo default" ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: 'antes de pressionar ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: '"Selecionar".',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '4. ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: 'Configurações',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ': Permite selecionar a pasta onde serão armazenados os dados da aquisição, a frequência de amostragem, os canais a adquirir em cada um dos dispositivos e a que sensores correspondem esses canais. Permite ainda guardar estas configurações como default.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '5. Pressionar o botão ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: '"Iniciar" ',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'para iniciar a aquisição. Irá ser direcionado para a página de visualização. É normal demorar alguns segundos até ser feito o display dos sinais.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  '6. Para adicionar uma anotação (ex: Crise, Mudança de bateria, etc...), pressionar o botão à esquerda. ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text:
                                  'Pode selecionar uma anotação já existente (',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          WidgetSpan(
                              child: Icon(Icons.arrow_drop_down,
                                  color: Colors.grey[600])),
                          TextSpan(
                              text:
                                  ') ou adicionar uma nova (por escrita). Poderá também retificar o instante de ocorrência ou, caso não seja possível, selecionar a caixa ( ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          WidgetSpan(
                              child: Icon(Icons.check_box_outline_blank,
                                  color: Colors.grey[600])),
                          TextSpan(
                              text: ').',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  '6. Para terminar a aquisição e guardar os dados, pressionar o botão ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                          TextSpan(
                              text: '"Parar"',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: '.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'RESOLUÇÃO DE PROBLEMAS',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Não me consigo conectar ao servidor ou ao wifi PreEpiSeizures.',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'O Raspberry Pi pode não ter tido tempo suficiente de iniciar o sistema, espere 1 min e volte a tentar. Caso o problema persista, desligue o Raspberry Pi e tente novamente.',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Os passos 2, 3 e 4 não funcionam.',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Se um passo não se encontra disponível, significa que existem passos anteriores por finalizar. ',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Em "Selecionar dispositivos", aparece "Endereço MAC" em vez dos números.',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Isto significa que o processo não foi iniciado corretamente. Verificar a conexão com o servidor e reininciar o processo.',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Em "Configurações", não consigo selecionar os canais/sensores de um (ou ambos) os dispositivos.',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Apenas é possível selecionar os canais/sensores do(s) dispositivo(s) que foram selecionados no passo 2. ',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Sai da aplicação durante uma aquisição. Tenho de reiniciar o processo?',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Se a aquisição ainda estiver a decorrer (o botão "Parar" não foi pressionado), basta conectar-se ao servidor e o passo 4 "Iniciar visualização" deverá ficar disponível.',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              '...',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          ' ',
                          textAlign: TextAlign.justify,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ),
                  ]),
                ),
              ),
            ),
          ),

        ]),
      ),
    );
  }
}
