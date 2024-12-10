fun main() {
    val topographicMap = readInput("Day10")
        .map { row ->
            row.map { it.digitToInt() }
        }

    val topologicalMapHeight = topographicMap.size
    val topologicalMapWidth = topographicMap[0].size

    val zeros = mutableSetOf<Pair<Int, Int>>()
    val nines = mutableSetOf<Pair<Int, Int>>()
    topographicMap.forEachIndexed { rowIndex, row ->
        row.forEachIndexed { colIndex, cell ->
            when (cell) {
                0 -> zeros.add(rowIndex to colIndex)
                9 -> nines.add(rowIndex to colIndex)
            }
        }
    }

    fun manhattanDistance(start: Pair<Int, Int>, end: Pair<Int, Int>) =
        start.first - end.first + start.second - end.second

    fun dfs(startCoord: Pair<Int, Int>, endCoord: Pair<Int, Int>, height: Int): Int = when {
        startCoord.first !in 0..<topologicalMapHeight || startCoord.second !in 0..<topologicalMapWidth -> 0
        topographicMap[startCoord.first][startCoord.second] != height -> 0
        height == 9 && startCoord == endCoord -> 1
        else -> {
            dfs(startCoord.first - 1 to startCoord.second, endCoord, height + 1) +
                    dfs(startCoord.first + 1 to startCoord.second, endCoord, height + 1) +
                    dfs(startCoord.first to startCoord.second - 1, endCoord, height + 1) +
                    dfs(startCoord.first to startCoord.second + 1, endCoord, height + 1)
        }
    }

    var rating = 0
    zeros.forEachIndexed { zeroIndex, zeroCoord ->
        nines.forEachIndexed { nineIndex, nineCoord ->
            if (manhattanDistance(zeroCoord, nineCoord) <= 9) {
                rating += dfs(zeroCoord, nineCoord, 0)
            }
        }
    }

    println(rating)

}
