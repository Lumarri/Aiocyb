import 'dart:convert';
import 'dart:io';

import 'package:aiocyb/src/data/offline_labs.dart';

void main() => stdout.writeln(
  jsonEncode([
    for (final lab in offlineLabs)
      {
        'id': lab.id,
        'title': lab.title,
        'description': lab.description,
        'closure': lab.closure,
        'stages': [
          for (final stage in lab.stages)
            {
              'title': stage.title,
              'evidence': stage.evidence,
              'task': stage.task,
              'options': stage.options,
              'answer': stage.answer,
              'feedback': stage.feedback,
              'intro': stage.intro,
              'correct': stage.correct,
              'soft': stage.soft,
              'sharp': stage.sharp,
            },
        ],
      },
  ]),
);
