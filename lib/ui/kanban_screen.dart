import 'package:flutter/material.dart';
import 'package:kanban_list_app/provider/kanban_provider.dart';
import 'package:provider/provider.dart';
import 'package:kanban_list_app/models/board.dart';
import 'package:kanban_list_app/models/item.dart';
import 'package:intl/intl.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size dpSize = MediaQuery.of(context).size;
    KanbanProvider vm = Provider.of<KanbanProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kanban List Task"),
      ),
      body: Container(
        width: dpSize.width,
        height: dpSize.height,
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  vm.getBoards.map((e) => _buildBoard(context, vm, e)).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNewBoardDialog(
            context,
            vm,
          );
        },
        tooltip: 'Add New Board',
        child: const Icon(Icons.add),
      ),
    );
  }

  void showNewBoardDialog(
    BuildContext context,
    KanbanProvider kpv,
  ) {
    TextEditingController controller = TextEditingController();
    AlertDialog dialog = AlertDialog(
      title: const Text('Add Board'),
      content: TextField(
        controller: controller,
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("CANCEL"),
        ),
        MaterialButton(
          onPressed: () {
            kpv.addBoard(controller.value.text);
            Navigator.pop(context);
          },
          child: const Text("SAVE"),
        )
      ],
    );
    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: true,
    );
  }

  void showNewItemDialog(
      BuildContext context, KanbanProvider kpv, int boardId) {
    TextEditingController controller = TextEditingController();
    AlertDialog dialog = AlertDialog(
      title: const Text("Add Item"),
      content: TextField(
        controller: controller,
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("CANCEL"),
        ),
        MaterialButton(
          onPressed: () {
            kpv.addItem(controller.value.text, boardId);
            Navigator.pop(context);
          },
          child: const Text("SAVE"),
        )
      ],
    );

    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: true,
    );
  }

  void showEditItemDialog(
      BuildContext context, KanbanProvider kpv, Item item, int boardId) {
    TextEditingController controller = TextEditingController();
    AlertDialog dialog = AlertDialog(
      title: const Text("Edit Item"),
      content: TextField(
        controller: controller..text = item.name,
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("CANCEL"),
        ),
        MaterialButton(
          onPressed: () {
            kpv.editItem(item, boardId, controller.value.text);
            //
            Navigator.pop(context);
          },
          child: const Text("SAVE"),
        )
      ],
    );

    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: true,
    );
  }

  void showDeleteItemDialog(
      BuildContext context, KanbanProvider kpv, Item item, int boardId) {
    AlertDialog dialog = AlertDialog(
      title: Text("Delete ${item.name}"),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("CANCEL"),
        ),
        MaterialButton(
          onPressed: () {
            kpv.deleteItem(item, boardId);
            Navigator.pop(context);
          },
          child: const Text("DELETE"),
        )
      ],
    );

    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: true,
    );
  }

  void showDeleteBoardDialog(
      BuildContext context, KanbanProvider kpv, board, int boardId) {
    AlertDialog dialog = AlertDialog(
      title: Text("Delete ${board.name}"),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("CANCEL"),
        ),
        MaterialButton(
          onPressed: () {
            kpv.deleteBoardItem(board);
            Navigator.pop(context);
          },
          child: const Text("DELETE"),
        )
      ],
    );

    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: true,
    );
  }

  Widget _buildBoard(BuildContext context, KanbanProvider kpv, Board board) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: 350,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          color: Color.fromRGBO(207, 207, 207, 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(board.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(DateTime.fromMicrosecondsSinceEpoch(
                              board.date * 1000))
                          .toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: board.items
                      .map((e) =>
                          _buildItem(context, e, board, kpv, board.items))
                      .toList(),
                ),
              ),
              _buildNewItem(context, kpv, board.id),
              Container(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () =>
                      showDeleteBoardDialog(context, kpv, board, board.id),
                  child: const Icon(Icons.delete, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, Item item, Board board,
      KanbanProvider kpv, listItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (listItems.indexOf(item) != 0) ...[
                GestureDetector(
                    onTap: () =>
                        kpv.moveItem(listItems, listItems.indexOf(item), false),
                    child: const Icon(Icons.keyboard_arrow_up_outlined)),
                GestureDetector(
                    onTap: () =>
                        kpv.moveItem(listItems, listItems.indexOf(item), true),
                    child: const Icon(Icons.keyboard_arrow_down_outlined))
              ]
            ],
          ),
          title: GestureDetector(
              onTap: () => showEditItemDialog(context, kpv, item, board.id),
              child: Text(item.name)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: board.id != 0,
                child: GestureDetector(
                  onTap: () => kpv.moveItemBoard(item, board, false),
                  child: const Icon(Icons.keyboard_arrow_left_outlined),
                ),
              ),
              if (board.id != kpv.getBoards.last.id)
                GestureDetector(
                    onTap: () => kpv.moveItemBoard(item, board, true),
                    child: const Icon(Icons.keyboard_arrow_right_outlined)),
            ],
          ),
          onTap: () => showEditItemDialog(context, kpv, item, board.id),
          onLongPress: () => showDeleteItemDialog(context, kpv, item, board.id),
        ),
      ),
    );
  }

  Widget _buildNewItem(BuildContext context, KanbanProvider kpv, int boardId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: const Center(child: Icon(Icons.add, size: 30)),
          onTap: () => showNewItemDialog(context, kpv, boardId),
        ),
      ),
    );
  }
}
