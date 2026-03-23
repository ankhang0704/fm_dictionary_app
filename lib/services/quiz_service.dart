import '../models/word_model.dart';

class QuizService {
  static List<Map<String, dynamic>> generateQuiz(List<Word> targetWords, List<Word> distractorPool, int questionCount) {
    List<Map<String, dynamic>> quizData = [];
    
    // Xáo trộn danh sách từ mục tiêu và lấy số lượng câu hỏi yêu cầu
    List<Word> shuffledTargets = List.from(targetWords)..shuffle();
    shuffledTargets = shuffledTargets.take(questionCount).toList();

    for (var correctWord in shuffledTargets) {
      // Lấy danh sách các từ khác từ pool (loại trừ từ đúng)
      List<String> otherWords = distractorPool
          .where((w) => w.word != correctWord.word)
          .map((w) => w.word)
          .toSet() // Đảm bảo không trùng lặp
          .toList();
      
      otherWords.shuffle();
      
      // Lấy tối đa 3 từ sai + 1 từ đúng
      List<String> options = otherWords.take(3).toList();
      options.add(correctWord.word);
      options.shuffle(); // Xáo trộn thứ tự đáp án

      quizData.add({
        'question': correctWord.meaning,
        'options': options,
        'correctAnswer': correctWord.word,
        'wordObj': correctWord,
      });
    }
    return quizData;
  }
}
