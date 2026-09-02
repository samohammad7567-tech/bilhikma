class LessonTestMock {
  LessonTestMock._();

  static Map<String, dynamic> test(String lessonId) => <String, dynamic>{
    'id': 'test-$lessonId',
    'lesson_id': lessonId,
    'title': 'تفسير الدرس (1)',
    'duration': 600,
    'pass_percent': 70,
    'retry_after_days': 3,
    'questions': <Map<String, dynamic>>[
      _singleChoice,
      _multiChoice,
      _mostCorrect,
      _trueFalse,
      _fillSingleBlank,
      _fillManyBlanks,
      _typedBlank,
      _matchPairs,
      _orderSentences,
      _closingChoice,
    ],
  };

  static const Map<String, dynamic> _singleChoice = <String, dynamic>{
    'id': 'q1',
    'type': 'single_choice',
    'prompt': 'ما هو ترتيب مصادر التشريع الإسلامي الأول ؟',
    'time_limit': 45,
    'options': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q1-a',
        'label': 'الجواب الأول',
        'is_correct': true,
      },
      <String, dynamic>{'id': 'q1-b', 'label': 'الجواب الثاني'},
      <String, dynamic>{'id': 'q1-c', 'label': 'الجواب الثالث'},
      <String, dynamic>{'id': 'q1-d', 'label': 'الجواب الرابع'},
    ],
  };

  static const Map<String, dynamic> _multiChoice = <String, dynamic>{
    'id': 'q2',
    'type': 'multi_choice',
    'prompt': 'اختر إجابتين صحيحتين من مصادر التشريع الإسلامي',
    'time_limit': 45,
    'options': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q2-a',
        'label': 'الجواب الأول',
        'is_correct': true,
      },
      <String, dynamic>{
        'id': 'q2-b',
        'label': 'الجواب الثاني',
        'is_correct': true,
      },
      <String, dynamic>{'id': 'q2-c', 'label': 'الجواب الثالث'},
      <String, dynamic>{'id': 'q2-d', 'label': 'الجواب الرابع'},
    ],
  };

  static const Map<String, dynamic> _mostCorrect = <String, dynamic>{
    'id': 'q3',
    'type': 'most_correct',
    'prompt': 'اختر الإجابة الأكثر صحة من بين الإجابات الآتية',
    'time_limit': 45,
    'options': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q3-a',
        'label': 'الجواب الأول',
        'is_correct': true,
        'is_most_correct': true,
      },
      <String, dynamic>{
        'id': 'q3-b',
        'label': 'الجواب الثاني',
        'is_correct': true,
      },
      <String, dynamic>{'id': 'q3-c', 'label': 'الجواب الثالث'},
      <String, dynamic>{'id': 'q3-d', 'label': 'الجواب الرابع'},
    ],
  };

  static const Map<String, dynamic> _trueFalse = <String, dynamic>{
    'id': 'q4',
    'type': 'true_false',
    'prompt': 'القرآن الكريم هو المصدر الأول من مصادر التشريع الإسلامي',
    'time_limit': 45,
    'options': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q4-true',
        'label': 'العبارة صحيحة',
        'is_correct': true,
      },
      <String, dynamic>{'id': 'q4-false', 'label': 'العبارة خاطئة'},
    ],
  };

  static const Map<String, dynamic> _fillSingleBlank = <String, dynamic>{
    'id': 'q5',
    'type': 'fill_blanks',
    'prompt': 'املأ الفراغ في الجملة الآتية بما يناسبها:',
    'body':
        'معنى قوله تعالى: (وَالْعَصْرِ) أنَّ الله تَعالى أقْسم بـ ({{q5-b1}})',
    'time_limit': 45,
    'blanks': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'q5-b1', 'correct_option_id': 'q5-o1'},
    ],
    'options': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'q5-o1', 'label': 'الزَّمن أو العصر'},
      <String, dynamic>{'id': 'q5-o2', 'label': 'خُسْر'},
      <String, dynamic>{'id': 'q5-o3', 'label': 'قصير'},
      <String, dynamic>{'id': 'q5-o4', 'label': 'متعدد'},
    ],
  };

  static const Map<String, dynamic> _fillManyBlanks = <String, dynamic>{
    'id': 'q6',
    'type': 'fill_blanks',
    'prompt': 'املأ الفراغ في الجملة الآتية بما يناسبها:',
    'body':
        'معنى قوله تعالى: (وَالْعَصْرِ) أنَّ الله تَعالى أقْسم بـ ({{q6-b1}})، '
        'وجوابُ القَسم أقْسم عليْهِ في قَوْلِهِ: (إنَّ الْإنْسانَ لفي خُسْرٍ) '
        'أنَّ كُلَّ إنْسان في ({{q6-b2}}) وهَلاكٍ، إلّا الَّذين آمَنوا وعَمِلوا '
        'الصّالِحات.',
    'time_limit': 60,
    'blanks': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'q6-b1', 'correct_option_id': 'q6-o1'},
      <String, dynamic>{'id': 'q6-b2', 'correct_option_id': 'q6-o2'},
    ],
    'options': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'q6-o1', 'label': 'الزَّمن أو العصر'},
      <String, dynamic>{'id': 'q6-o2', 'label': 'خُسْر'},
      <String, dynamic>{'id': 'q6-o3', 'label': 'قصير'},
      <String, dynamic>{'id': 'q6-o4', 'label': 'متعدد'},
      <String, dynamic>{'id': 'q6-o5', 'label': 'هلاك'},
    ],
  };

  static const Map<String, dynamic> _typedBlank = <String, dynamic>{
    'id': 'q7',
    'type': 'typed_blanks',
    'prompt': 'املأ الفراغ في الجملة الآتية بما يناسبها:',
    'body':
        'معنى قوله تعالى: (وَالْعَصْرِ) أنَّ الله تَعالى أقْسم بـ ({{q7-b1}})',
    'time_limit': 60,
    'blanks': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q7-b1',
        'accepted_answers': <String>['الزمن أو العصر', 'الزمن', 'العصر'],
      },
    ],
  };

  static const Map<String, dynamic> _matchPairs = <String, dynamic>{
    'id': 'q8',
    'type': 'match_pairs',
    'prompt': 'اضغط على الجملة و مايقابلها في المعنى :',
    'time_limit': 90,
    'pairs': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q8-p1',
        'prompt': 'ثم بين الله تعالى عظمته وقدرته بآية الكرسي.',
        'match': 'بيان عظمة الله تعالى وقدرته في آية الكرسي.',
      },
      <String, dynamic>{
        'id': 'q8-p2',
        'prompt': 'نزلت هذه الآية الكريمة لتوضح توحيد الله وتنزهه عن الشريك.',
        'match': 'توضيح توحيد الله وتنزيهه عن الشريك.',
      },
      <String, dynamic>{
        'id': 'q8-p3',
        'prompt': 'فأوصى المسلمون بتلاوتها لحفظهم من كل شر.',
        'match': 'الوصية بتلاوتها للحفظ من كل شر.',
      },
      <String, dynamic>{
        'id': 'q8-p4',
        'prompt': 'فوعى الصحابة هذا المعنى العظيم وحفظوه.',
        'match': 'وعي الصحابة لهذا المعنى وحفظهم له.',
      },
    ],
  };

  static const Map<String, dynamic> _orderSentences = <String, dynamic>{
    'id': 'q9',
    'type': 'order_sentences',
    'prompt':
        'رتب الجمل الآتية لتكون فقرة صحيحة تسرد قصة نزول أو معنى إجمالي '
        'لآية الكرسي :',
    'time_limit': 90,
    'sentences': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'q9-s1',
        'text': 'نزلت هذه الآية الكريمة لتوضح توحيد الله وتنزهه عن الشريك.',
        'position': 1,
      },
      <String, dynamic>{
        'id': 'q9-s2',
        'text': 'ثم بين الله تعالى عظمته وقدرته بآية الكرسي.',
        'position': 2,
      },
      <String, dynamic>{
        'id': 'q9-s3',
        'text': 'فأوصى المسلمون بتلاوتها لحفظهم من كل شر.',
        'position': 3,
      },
      <String, dynamic>{
        'id': 'q9-s4',
        'text': 'فوعى الصحابة هذا المعنى العظيم وحفظوه.',
        'position': 4,
      },
    ],
  };

  static const Map<String, dynamic> _closingChoice = <String, dynamic>{
    'id': 'q10',
    'type': 'single_choice',
    'prompt': 'ما الفائدة الأولى المستفادة من سورة العصر ؟',
    'time_limit': 45,
    'options': <Map<String, dynamic>>[
      <String, dynamic>{'id': 'q10-a', 'label': 'الجواب الأول'},
      <String, dynamic>{
        'id': 'q10-b',
        'label': 'الجواب الثاني',
        'is_correct': true,
      },
      <String, dynamic>{'id': 'q10-c', 'label': 'الجواب الثالث'},
      <String, dynamic>{'id': 'q10-d', 'label': 'الجواب الرابع'},
    ],
  };
}
