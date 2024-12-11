import sys
from typing import List, Tuple

def parse_disk_map(disk_map: str) -> List[str]:

    blocks = []
    file_id = 0  # Start file IDs from '0'

    i = 0
    while i < len(disk_map):
        file_length = int(disk_map[i])
        i += 1

        if i < len(disk_map):
            free_length = int(disk_map[i])
            i += 1
        else:
            free_length = 0  # Assume no free space if not specified

        # Append file blocks
        blocks.extend([str(file_id)] * file_length)
        file_id += 1

        # Append free space blocks
        if free_length > 0:
            blocks.extend(['.'] * free_length)

    return blocks

def compact_disk_part1(blocks: List[str]) -> List[str]:
    while True:
        try:
            # Find the first free space from the left
            free_index = blocks.index('.')
        except ValueError:
            # No free space left
            break

        # Find the rightmost file block after the free space
        for i in range(len(blocks) - 1, free_index, -1):
            if blocks[i] != '.':
                # Move the file block to the free space
                blocks[free_index] = blocks[i]
                blocks[i] = '.'
                break
        else:
            # No file block found after the free space
            break

    return blocks

def find_files(blocks: List[str]) -> List[Tuple[int, int, str]]:
    files = []
    i = 0
    while i < len(blocks):
        if blocks[i] != '.':
            start = i
            current_id = blocks[i]
            while i < len(blocks) and blocks[i] == current_id:
                i += 1
            end = i - 1
            files.append((start, end, current_id))
        else:
            i += 1
    return files

def find_free_spans(blocks: List[str]) -> List[Tuple[int, int]]:
    """
    Identifies all free space spans on the disk.
    Returns a list of tuples: (start_index, length)
    """
    free_spans = []
    i = 0
    while i < len(blocks):
        if blocks[i] == '.':
            start = i
            while i < len(blocks) and blocks[i] == '.':
                i += 1
            length = i - start
            free_spans.append((start, length))
        else:
            i += 1
    return free_spans

def compact_disk_part2(blocks: List[str]) -> List[str]:
    files = find_files(blocks)

    files_sorted = sorted(files, key=lambda x: int(x[2]), reverse=True)

    for file in files_sorted:
        start, end, file_id = file
        file_size = end - start + 1

        free_spans = find_free_spans(blocks)

        # Sort free spans by start index to find the leftmost first
        free_spans_sorted = sorted(free_spans, key=lambda x: x[0])

        # Attempt to find the earliest free span that can fit the file
        for span_start, span_length in free_spans_sorted:
            if span_length >= file_size and span_start + span_length <= start:
                # Move the file to this span
                # Replace the free space with the file
                for i in range(file_size):
                    blocks[span_start + i] = file_id

                # Replace the original file blocks with free spaces
                for i in range(start, end + 1):
                    blocks[i] = '.'

                break  # Move to the next file after successful move

    return blocks

def calculate_checksum(blocks: List[str]) -> int:
    checksum = 0
    for position, block in enumerate(blocks):
        if block != '.':
            checksum += position * int(block)
    return checksum

def main():
    if len(sys.argv) != 2:
        print("Usage: python disk_fragmenter.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]

    with open(input_file, 'r') as file:
        disk_map = file.read().strip()

    blocks = parse_disk_map(disk_map)


    # --- Part 1: Moving Individual Blocks ---
    blocks_part1 = blocks.copy()
    compacted_part1 = compact_disk_part1(blocks_part1)
    checksum_part1 = calculate_checksum(compacted_part1)
    print("\n--- Part 1: Moving Individual Blocks ---")
    print("Filesystem Checksum:", checksum_part1)

    # --- Part 2: Moving Entire Files ---
    blocks_part2 = blocks.copy()
    compacted_part2 = compact_disk_part2(blocks_part2)
    checksum_part2 = calculate_checksum(compacted_part2)
    print("\n--- Part 2: Moving Entire Files ---")
    print("Filesystem Checksum:", checksum_part2)

if __name__ == "__main__":
    main()
