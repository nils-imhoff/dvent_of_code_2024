import numpy as np
import argparse
from collections import Counter

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Calculate total distance and similarity score between two lists of numbers.")
    parser.add_argument('file_path', type=str, help="Path to the text file containing the two lists.")
    args = parser.parse_args()

    # Read data from the file
    left_list, right_list = read_data_from_file(args.file_path)

    # Compute total distance
    total_distance = calculate_total_distance(left_list, right_list)
    print(f"The total distance is: {total_distance}")

    # Compute similarity score
    similarity_score = calculate_similarity_score(left_list, right_list)
    print(f"The similarity score is: {similarity_score}")

def read_data_from_file(file_path):
    # Load data and split into two lists
    data = np.loadtxt(file_path)
    left_list = data[:, 0]  # First column
    right_list = data[:, 1]  # Second column
    return left_list, right_list

def calculate_total_distance(left_list, right_list):
    # Sort both lists
    left_list_sorted = np.sort(left_list)
    right_list_sorted = np.sort(right_list)

    # Calculate pairwise distances
    distances = np.abs(left_list_sorted - right_list_sorted)

    # Sum distances
    total_distance = np.sum(distances)
    return total_distance

def calculate_similarity_score(left_list, right_list):
    # Count the occurrences of each number in the right list
    right_list_counts = Counter(right_list)

    # Calculate the similarity score
    similarity_score = sum(num * right_list_counts[num] for num in left_list)
    return similarity_score

if __name__ == "__main__":
    main()
