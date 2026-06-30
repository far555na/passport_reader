import 'dart:math';

class FaceMatchUtils {
  /// Calculates the Euclidean distance between two embeddings (vectors).
  /// A common threshold for MobileFaceNet is < 1.0 for a match.
  static double calculateEuclideanDistance(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same length');
    }
    double sum = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      double diff = embedding1[i] - embedding2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  /// Calculates the Cosine Similarity between two embeddings.
  /// Result is between -1.0 and 1.0. Higher is more similar.
  /// A common threshold for MobileFaceNet is > 0.4 for a match.
  static double calculateCosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same length');
    }
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      normA += embedding1[i] * embedding1[i];
      normB += embedding2[i] * embedding2[i];
    }
    
    if (normA == 0.0 || normB == 0.0) return 0.0;
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
