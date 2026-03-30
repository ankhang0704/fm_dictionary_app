/// Abstract base — swap engine mà không đụng vào TtsService
abstract class TtsEngine {
  Future<void> warmUp();          // Khởi tạo phần cứng âm thanh ngay lúc app mở
  Future<void> speak(String text, {String? accent, double? speed});
  Future<void> stop();
  Future<void> dispose();         // Giải phóng tài nguyên khi chuyển màn hình
}