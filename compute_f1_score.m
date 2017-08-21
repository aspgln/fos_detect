function score = compute_f1_score(tp, fp, fn)

precision = tp / (tp + fp);
recall = tp / (tp + fn);
score = 2 * precision * recall / (precision + recall);