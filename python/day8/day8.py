import sys
from itertools import combinations
from typing import List, Tuple, Dict, Set

def read_input(file_path: str) -> List[str]:
    with open(file_path, 'r') as file:
        return file.read().splitlines()

def find_antennas(grid: List[str]) -> Dict[str, List[Tuple[int, int]]]:
    antennas = {}
    for y, row in enumerate(grid):
        for x, cell in enumerate(row):
            if cell != '.':
                antennas.setdefault(cell, []).append((x, y))
    return antennas

def compute_antinode(p1: Tuple[int, int], p2: Tuple[int, int]) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    x1, y1 = p1
    x2, y2 = p2
    dx = x2 - x1
    dy = y2 - y1
    # Antinode 1: Extend from p1 by the vector (-dx, -dy)
    antinode1 = (x1 - dx, y1 - dy)
    # Antinode 2: Extend from p2 by the vector (dx, dy)
    antinode2 = (x2 + dx, y2 + dy)
    return antinode1, antinode2

def get_grid_bounds(grid: List[str]) -> Tuple[int, int]:
    max_y = len(grid)
    max_x = max(len(row) for row in grid) if grid else 0
    return max_x, max_y

def is_within_grid(pos: Tuple[int, int], max_x: int, max_y: int) -> bool:
    x, y = pos
    return 0 <= x < max_x and 0 <= y < max_y

def calculate_unique_antinode_positions_part1(grid: List[str]) -> int:
    antennas = find_antennas(grid)
    max_x, max_y = get_grid_bounds(grid)
    antinode_positions: Set[Tuple[int, int]] = set()

    for freq, points in antennas.items():
        if len(points) < 2:
            continue  # Need at least two antennas to form antinodes
        for p1, p2 in combinations(points, 2):
            ant1, ant2 = compute_antinode(p1, p2)
            if is_within_grid(ant1, max_x, max_y):
                antinode_positions.add(ant1)
            if is_within_grid(ant2, max_x, max_y):
                antinode_positions.add(ant2)

    return len(antinode_positions)

def calculate_antinodes_part2(grid: List[str]) -> int:
    antennas = find_antennas(grid)
    max_x, max_y = get_grid_bounds(grid)
    antinode_positions: Set[Tuple[int, int]] = set()

    for freq, points in antennas.items():
        if len(points) < 2:
            continue  # Need at least two antennas to form antinodes in part 2
        # Generate all unique pairs of antennas for this frequency
        for p1, p2 in combinations(points, 2):
            # Define the line in ax + by + c = 0 form
            a = p2[1] - p1[1]
            b = p1[0] - p2[0]
            c = p2[0]*p1[1] - p1[0]*p2[1]
            # Iterate over all grid positions and check if they lie on the line
            for y in range(max_y):
                for x in range(max_x):
                    if a * x + b * y + c == 0:
                        antinode_positions.add((x, y))

    return len(antinode_positions)

def main():
    if len(sys.argv) != 2:
        print("Usage: python day_antinode.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    grid = read_input(input_file)

    # Part 1: Original Antinode Calculation
    result_part1 = calculate_unique_antinode_positions_part1(grid)
    print("Part 1: Total Unique Antinode Locations:", result_part1)

    # Part 2: Updated Antinode Calculation
    result_part2 = calculate_antinodes_part2(grid)
    print("Part 2: Total Unique Antinode Locations:", result_part2)

if __name__ == "__main__":
    main()
