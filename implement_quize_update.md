{
    "message": "تم تسليم المحاولة وتصحيحها بنجاح.",
    "status_code": 1,
    "data": {
        "id": 361,
        "quiz_id": 17,
        "assessment_id": 17,
        "student_id": 10,
        "attempt_no": 75,
        "score": 2,
        "max_score": 56,
        "score_percent": 4,
        "is_passed": false,
        "review_status": "none",
        "started_at": "2026-11-08T09:58:01+00:00",
        "expires_at": null,
        "submitted_at": "2026-11-08T09:58:27+00:00",
        "duration_seconds": 26,
        "has_expired": false,
        "auto_submitted": false,
        "server_now": "2026-11-08T09:58:28+00:00",
        "policy_snapshot": {
            "pass_score": 100,
            "is_blocking": false,
            "max_attempts": null,
            "shuffle_questions": false,
            "time_limit_minutes": null,
            "retry_cooldown_minutes": 0,
            "question_timing_enabled": true
        },
        "question_timing_enabled": true,
        "ignored_question_ids": [],
        "answers": [
            {
                "question_id": 38,
                "question_text": "01 - اختر البطاقة الحمراء بعد الاستماع إلى الصوت",
                "question_type": "mcq_single",
                "tags": [],
                "score": 4,
                "default_time_seconds": 45,
                "timer": {
                    "enabled": true,
                    "started_at": "2026-11-08T09:58:02+00:00",
                    "expires_at": "2026-11-08T09:58:47+00:00",
                    "seconds_left": 19,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "all_or_nothing",
                    "question_format": "plain",
                    "image_path": "https://bilhikma.tech/storage/qa-quiz-fields/card-a.png",
                    "audio_path": "qa-quiz-fields/tone.wav",
                    "default_time_seconds": 45,
                    "details": {
                        "options": [
                            {
                                "id": "green",
                                "text": "الخضراء",
                                "image_path": "qa-quiz-fields/card-c.png"
                            },
                            {
                                "id": "blue",
                                "text": "الزرقاء",
                                "image_path": "qa-quiz-fields/card-b.png"
                            },
                            {
                                "id": "red",
                                "text": "الحمراء",
                                "image_path": "qa-quiz-fields/card-a.png"
                            }
                        ],
                        "choice_variant": "best_answer"
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "options": [
                            {
                                "id": "red",
                                "text": "الحمراء",
                                "feedback": "تفسير الخيار red",
                                "image_path": "qa-quiz-fields/card-a.png",
                                "is_correct": true
                            },
                            {
                                "id": "blue",
                                "text": "الزرقاء",
                                "feedback": "تفسير الخيار blue",
                                "image_path": "qa-quiz-fields/card-b.png",
                                "is_correct": false
                            },
                            {
                                "id": "green",
                                "text": "الخضراء",
                                "feedback": "تفسير الخيار green",
                                "image_path": "qa-quiz-fields/card-c.png",
                                "is_correct": false
                            }
                        ],
                        "choice_variant": "best_answer",
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: الاختيار بإجابة واحدة مع صورة وصوت"
                }
            },
            {
                "question_id": 39,
                "question_text": "02 - اختر رقمين زوجيين فقط",
                "question_type": "mcq_multiple",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_with_penalty",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "options": [
                            {
                                "id": "four",
                                "text": "أربعة",
                                "image_path": null
                            },
                            {
                                "id": "three",
                                "text": "ثلاثة",
                                "image_path": null
                            },
                            {
                                "id": "two",
                                "text": "اثنان",
                                "image_path": null
                            },
                            {
                                "id": "five",
                                "text": "خمسة",
                                "image_path": null
                            }
                        ],
                        "max_selections": 2
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": false,
                "answer_status": "partial",
                "awarded_score": 2,
                "given_answer": {
                    "option_ids": [
                        "four"
                    ]
                },
                "solution": {
                    "details": {
                        "options": [
                            {
                                "id": "two",
                                "text": "اثنان",
                                "feedback": "تفسير الخيار two",
                                "image_path": null,
                                "is_correct": true
                            },
                            {
                                "id": "four",
                                "text": "أربعة",
                                "feedback": "تفسير الخيار four",
                                "image_path": null,
                                "is_correct": true
                            },
                            {
                                "id": "three",
                                "text": "ثلاثة",
                                "feedback": "تفسير الخيار three",
                                "image_path": null,
                                "is_correct": false
                            },
                            {
                                "id": "five",
                                "text": "خمسة",
                                "feedback": "تفسير الخيار five",
                                "image_path": null,
                                "is_correct": false
                            }
                        ],
                        "max_selections": 2,
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: الاختيار المتعدد وحد الاختيارات"
                }
            },
            {
                "question_id": 40,
                "question_text": "03 - البطاقة الظاهرة حمراء. العبارة صحيحة أم خاطئة؟",
                "question_type": "true_false",
                "tags": [],
                "score": 4,
                "default_time_seconds": 45,
                "timer": {
                    "enabled": true,
                    "started_at": "2026-11-08T09:58:12+00:00",
                    "expires_at": "2026-11-08T09:58:57+00:00",
                    "seconds_left": 29,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "audio_path": "qa-quiz-fields/tone.wav",
                    "image_path": "https://bilhikma.tech/storage/qa-quiz-fields/card-a.png",
                    "explanation": "شرح الإجابة الصحيحة: صح أو خطأ",
                    "correct_answer": true,
                    "question_format": "plain",
                    "default_time_seconds": 45
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0
            },
            {
                "question_id": 41,
                "question_text": "04 - عدد ركعات الفجر {{1}} وعدد ركعات المغرب {{2}}",
                "question_type": "fill_blank_choice",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "choices": [
                                    {
                                        "id": "two",
                                        "text": "ركعتان"
                                    },
                                    {
                                        "id": "three",
                                        "text": "ثلاث"
                                    }
                                ],
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 3
                            },
                            {
                                "id": "b2",
                                "choices": [
                                    {
                                        "id": "four",
                                        "text": "أربع"
                                    },
                                    {
                                        "id": "three",
                                        "text": "ثلاث"
                                    }
                                ],
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ],
                        "blank_input_mode": "dropdown"
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "choices": [
                                    {
                                        "id": "two",
                                        "text": "ركعتان",
                                        "is_correct": true
                                    },
                                    {
                                        "id": "three",
                                        "text": "ثلاث",
                                        "is_correct": false
                                    }
                                ],
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 3
                            },
                            {
                                "id": "b2",
                                "choices": [
                                    {
                                        "id": "three",
                                        "text": "ثلاث",
                                        "is_correct": true
                                    },
                                    {
                                        "id": "four",
                                        "text": "أربع",
                                        "is_correct": false
                                    }
                                ],
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ],
                        "schema_version": 1,
                        "blank_input_mode": "dropdown"
                    },
                    "explanation": "شرح الإجابة الصحيحة: الفراغات بالقائمة المنسدلة والأوزان"
                }
            },
            {
                "question_id": 42,
                "question_text": "05 - عاصمة سوريا {{1}} وعاصمة مصر {{2}}",
                "question_type": "fill_blank_choice",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 1
                            },
                            {
                                "id": "b2",
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ],
                        "word_bank": [
                            {
                                "id": "beirut",
                                "text": "بيروت",
                                "is_reusable": false
                            },
                            {
                                "id": "damascus",
                                "text": "دمشق",
                                "is_reusable": false
                            },
                            {
                                "id": "cairo",
                                "text": "القاهرة",
                                "is_reusable": false
                            }
                        ],
                        "blank_input_mode": "word_bank"
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 1
                            },
                            {
                                "id": "b2",
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ],
                        "word_bank": [
                            {
                                "id": "damascus",
                                "text": "دمشق",
                                "is_reusable": false,
                                "is_distractor": false,
                                "target_blank_index": 1
                            },
                            {
                                "id": "cairo",
                                "text": "القاهرة",
                                "is_reusable": false,
                                "is_distractor": false,
                                "target_blank_index": 2
                            },
                            {
                                "id": "beirut",
                                "text": "بيروت",
                                "is_reusable": false,
                                "is_distractor": true,
                                "target_blank_index": null
                            }
                        ],
                        "schema_version": 1,
                        "blank_input_mode": "word_bank"
                    },
                    "explanation": "شرح الإجابة الصحيحة: بنك الكلمات والمشتتات"
                }
            },
            {
                "question_id": 43,
                "question_text": "06 - كرر كلمة التوحيد: الله {{1}} والله {{2}}",
                "question_type": "fill_blank_choice",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 1
                            },
                            {
                                "id": "b2",
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ],
                        "word_bank": [
                            {
                                "id": "one",
                                "text": "واحد",
                                "is_reusable": true
                            },
                            {
                                "id": "unique",
                                "text": "أحد",
                                "is_reusable": false
                            }
                        ],
                        "blank_input_mode": "word_bank"
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 1
                            },
                            {
                                "id": "b2",
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ],
                        "word_bank": [
                            {
                                "id": "one",
                                "text": "واحد",
                                "is_reusable": true,
                                "is_distractor": false,
                                "target_blank_index": 1
                            },
                            {
                                "id": "unique",
                                "text": "أحد",
                                "is_reusable": false,
                                "is_distractor": false,
                                "target_blank_index": 2
                            }
                        ],
                        "schema_version": 1,
                        "blank_input_mode": "word_bank"
                    },
                    "explanation": "شرح الإجابة الصحيحة: إعادة استخدام الكلمات"
                }
            },
            {
                "question_id": 44,
                "question_text": "07 - اكتب إبراهيم دون همزة في {{1}} واكتب اسم مدينة في {{2}}",
                "question_type": "fill_blank_typed",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "max_length": 8,
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 1
                            },
                            {
                                "id": "b2",
                                "max_length": 5,
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1
                            }
                        ]
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "blanks": [
                            {
                                "id": "b1",
                                "accepted": [
                                    {
                                        "is_primary": true,
                                        "answer_text": "إبراهيم",
                                        "normalized_text": "ابراهيم"
                                    }
                                ],
                                "max_length": 8,
                                "blank_index": 1,
                                "placeholder": "أدخل الجواب 1",
                                "score_weight": 1,
                                "fuzzy_threshold": null,
                                "fuzzy_match_enabled": false,
                                "normalization_flags": {
                                    "ignore_shadda": true,
                                    "remove_tatweel": true,
                                    "collapse_spaces": true,
                                    "ignore_latin_case": true,
                                    "unify_taa_marbuta": true,
                                    "ignore_hamza_forms": true,
                                    "ignore_punctuation": true,
                                    "unify_alef_maqsura": true,
                                    "ignore_definite_article": false,
                                    "ignore_other_diacritics": true
                                }
                            },
                            {
                                "id": "b2",
                                "accepted": [
                                    {
                                        "is_primary": true,
                                        "answer_text": "دمشق",
                                        "normalized_text": "دمشق"
                                    },
                                    {
                                        "is_primary": false,
                                        "answer_text": "الشام",
                                        "normalized_text": "الشام"
                                    }
                                ],
                                "max_length": 5,
                                "blank_index": 2,
                                "placeholder": "أدخل الجواب 2",
                                "score_weight": 1,
                                "fuzzy_threshold": null,
                                "fuzzy_match_enabled": false,
                                "normalization_flags": {
                                    "ignore_shadda": true,
                                    "remove_tatweel": true,
                                    "collapse_spaces": true,
                                    "ignore_latin_case": true,
                                    "unify_taa_marbuta": true,
                                    "ignore_hamza_forms": true,
                                    "ignore_punctuation": true,
                                    "unify_alef_maqsura": true,
                                    "ignore_definite_article": false,
                                    "ignore_other_diacritics": true
                                }
                            }
                        ],
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: الفراغات الكتابية والتطبيع العربي"
                }
            },
            {
                "question_id": 45,
                "question_text": "08 - صل الصلاة بعدد ركعاتها واترك المشتت",
                "question_type": "matching",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "pairs": {
                            "left": [
                                {
                                    "id": "fajr",
                                    "text": "الفجر",
                                    "image_path": null
                                },
                                {
                                    "id": "maghrib",
                                    "text": "المغرب",
                                    "image_path": null
                                }
                            ],
                            "right": [
                                {
                                    "id": "right002",
                                    "text": "ثلاث",
                                    "image_path": null
                                },
                                {
                                    "id": "right001",
                                    "text": "ركعتان",
                                    "image_path": null
                                },
                                {
                                    "id": "right003",
                                    "text": "سبع",
                                    "image_path": null
                                }
                            ]
                        },
                        "allow_one_to_many_matching": false
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "pairs": [
                            {
                                "id": "fajr",
                                "right_id": "right001",
                                "left_text": "الفجر",
                                "right_text": "ركعتان",
                                "score_weight": 3,
                                "is_distractor": false,
                                "left_image_path": null,
                                "right_image_path": null
                            },
                            {
                                "id": "maghrib",
                                "right_id": "right002",
                                "left_text": "المغرب",
                                "right_text": "ثلاث",
                                "score_weight": 1,
                                "is_distractor": false,
                                "left_image_path": null,
                                "right_image_path": null
                            },
                            {
                                "id": "noise",
                                "right_id": "right003",
                                "left_text": null,
                                "right_text": "سبع",
                                "score_weight": null,
                                "is_distractor": true,
                                "left_image_path": null,
                                "right_image_path": null
                            }
                        ],
                        "schema_version": 1,
                        "allow_one_to_many_matching": false
                    },
                    "explanation": "شرح الإجابة الصحيحة: التوصيل مع مشتت وأوزان"
                }
            },
            {
                "question_id": 46,
                "question_text": "09 - صل اللون الأحمر بكل بطاقاته",
                "question_type": "matching",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "pairs": {
                            "left": [
                                {
                                    "id": "red1",
                                    "text": "أحمر",
                                    "image_path": null
                                },
                                {
                                    "id": "blue",
                                    "text": "أزرق",
                                    "image_path": null
                                }
                            ],
                            "right": [
                                {
                                    "id": "right005",
                                    "text": "بطاقة ثانية",
                                    "image_path": null
                                },
                                {
                                    "id": "right006",
                                    "text": "بطاقة ثالثة",
                                    "image_path": null
                                },
                                {
                                    "id": "right004",
                                    "text": "بطاقة أولى",
                                    "image_path": null
                                }
                            ]
                        },
                        "allow_one_to_many_matching": true
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "pairs": [
                            {
                                "id": "red1",
                                "right_id": "right004",
                                "left_text": "أحمر",
                                "right_text": "بطاقة أولى",
                                "score_weight": null,
                                "is_distractor": false,
                                "left_image_path": null,
                                "right_image_path": null
                            },
                            {
                                "id": "red2",
                                "right_id": "right005",
                                "left_text": "أحمر",
                                "right_text": "بطاقة ثانية",
                                "score_weight": null,
                                "is_distractor": false,
                                "left_image_path": null,
                                "right_image_path": null
                            },
                            {
                                "id": "blue",
                                "right_id": "right006",
                                "left_text": "أزرق",
                                "right_text": "بطاقة ثالثة",
                                "score_weight": null,
                                "is_distractor": false,
                                "left_image_path": null,
                                "right_image_path": null
                            }
                        ],
                        "schema_version": 1,
                        "allow_one_to_many_matching": true
                    },
                    "explanation": "شرح الإجابة الصحيحة: التوصيل واحد إلى متعدد"
                }
            },
            {
                "question_id": 47,
                "question_text": "10 - رتب الأعداد تصاعدياً",
                "question_type": "ordering",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "position_based",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "items": [
                            {
                                "id": "two",
                                "text": "اثنان",
                                "image_path": null
                            },
                            {
                                "id": "three",
                                "text": "ثلاثة",
                                "image_path": null
                            },
                            {
                                "id": "one",
                                "text": "واحد",
                                "image_path": null
                            },
                            {
                                "id": "four",
                                "text": "أربعة",
                                "image_path": null
                            }
                        ]
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "items": [
                            {
                                "id": "one",
                                "text": "واحد",
                                "image_path": null
                            },
                            {
                                "id": "two",
                                "text": "اثنان",
                                "image_path": null
                            },
                            {
                                "id": "three",
                                "text": "ثلاثة",
                                "image_path": null
                            },
                            {
                                "id": "four",
                                "text": "أربعة",
                                "image_path": null
                            }
                        ],
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: الترتيب بالموضع"
                }
            },
            {
                "question_id": 48,
                "question_text": "11 - اختر الصورة الحمراء؛ الخيارات صور فقط",
                "question_type": "mcq_single",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "all_or_nothing",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "options": [
                            {
                                "id": "blueimg",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-b.png"
                            },
                            {
                                "id": "redimg",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-a.png"
                            }
                        ],
                        "choice_variant": "standard"
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "options": [
                            {
                                "id": "redimg",
                                "text": "",
                                "feedback": "تفسير الخيار redimg",
                                "image_path": "qa-quiz-fields/card-a.png",
                                "is_correct": true
                            },
                            {
                                "id": "blueimg",
                                "text": "",
                                "feedback": "تفسير الخيار blueimg",
                                "image_path": "qa-quiz-fields/card-b.png",
                                "is_correct": false
                            }
                        ],
                        "choice_variant": "standard",
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: اختيار الصور"
                }
            },
            {
                "question_id": 49,
                "question_text": "12 - رتب البطاقات: الأحمر ثم الأزرق ثم الأخضر",
                "question_type": "ordering",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "exact_sequence",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "items": [
                            {
                                "id": "green",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-c.png"
                            },
                            {
                                "id": "blue",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-b.png"
                            },
                            {
                                "id": "red",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-a.png"
                            }
                        ]
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "items": [
                            {
                                "id": "red",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-a.png"
                            },
                            {
                                "id": "blue",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-b.png"
                            },
                            {
                                "id": "green",
                                "text": "",
                                "image_path": "qa-quiz-fields/card-c.png"
                            }
                        ],
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: ترتيب الصور"
                }
            },
            {
                "question_id": 50,
                "question_text": "13 - صل الصورة بصورتها",
                "question_type": "matching",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "partial_credit",
                    "question_format": "plain",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "pairs": {
                            "left": [
                                {
                                    "id": "red",
                                    "text": "",
                                    "image_path": "qa-quiz-fields/card-a.png"
                                },
                                {
                                    "id": "blue",
                                    "text": "",
                                    "image_path": "qa-quiz-fields/card-b.png"
                                }
                            ],
                            "right": [
                                {
                                    "id": "right008",
                                    "text": "",
                                    "image_path": "qa-quiz-fields/card-b.png"
                                },
                                {
                                    "id": "right007",
                                    "text": "",
                                    "image_path": "qa-quiz-fields/card-a.png"
                                }
                            ]
                        },
                        "allow_one_to_many_matching": false
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "pairs": [
                            {
                                "id": "red",
                                "right_id": "right007",
                                "left_text": "",
                                "right_text": "",
                                "score_weight": null,
                                "is_distractor": false,
                                "left_image_path": "qa-quiz-fields/card-a.png",
                                "right_image_path": "qa-quiz-fields/card-a.png"
                            },
                            {
                                "id": "blue",
                                "right_id": "right008",
                                "left_text": "",
                                "right_text": "",
                                "score_weight": null,
                                "is_distractor": false,
                                "left_image_path": "qa-quiz-fields/card-b.png",
                                "right_image_path": "qa-quiz-fields/card-b.png"
                            }
                        ],
                        "schema_version": 1,
                        "allow_one_to_many_matching": false
                    },
                    "explanation": "شرح الإجابة الصحيحة: توصيل الصور"
                }
            },
            {
                "question_id": 51,
                "question_text": "<p>14 - اختر <strong>الجواب الصحيح</strong> من النص المنسق<br>سطر ثانٍ للاختبار</p>",
                "question_type": "mcq_single",
                "tags": [],
                "score": 4,
                "default_time_seconds": null,
                "timer": {
                    "enabled": false,
                    "started_at": null,
                    "expires_at": null,
                    "seconds_left": null,
                    "has_expired": false,
                    "can_answer": false
                },
                "options": {
                    "schema_version": 1,
                    "scoring_policy": "all_or_nothing",
                    "question_format": "rich",
                    "image_path": null,
                    "audio_path": null,
                    "default_time_seconds": null,
                    "details": {
                        "options": [
                            {
                                "id": "yes",
                                "text": "نعم",
                                "image_path": null
                            },
                            {
                                "id": "no",
                                "text": "لا",
                                "image_path": null
                            }
                        ],
                        "choice_variant": "standard"
                    }
                },
                "selected_option_id": null,
                "selected_boolean": null,
                "answer_text": null,
                "is_correct": null,
                "answer_status": "incorrect",
                "awarded_score": 0,
                "given_answer": null,
                "solution": {
                    "details": {
                        "options": [
                            {
                                "id": "yes",
                                "text": "نعم",
                                "feedback": "تفسير الخيار yes",
                                "image_path": null,
                                "is_correct": true
                            },
                            {
                                "id": "no",
                                "text": "لا",
                                "feedback": "تفسير الخيار no",
                                "image_path": null,
                                "is_correct": false
                            }
                        ],
                        "choice_variant": "standard",
                        "schema_version": 1
                    },
                    "explanation": "شرح الإجابة الصحيحة: النص المنسق"
                }
            }
        ],
        "attempts_used": 75,
        "attempts_left": null,
        "next_attempt_at": null
    }
}