import kotlin.math.sign

fun main() {
    val lines = readInput("Day2")
        .map { line ->
            line.split(" ")
                .map { it.toInt() }
        }

    val reallySafeCount = lines.count { isSafe(it) || isReallySafe(it) }

    println(reallySafeCount)
}

private fun isSafe(line: List<Int>): Boolean {
    val sign = (line[1] - line[0]).sign
    return line.zipWithNext()
        .all { (a, b) ->
            sign * (b - a) in 1..3
        }
}

private fun isReallySafe(line: List<Int>): Boolean {
    val tries = buildList<List<Int>> {
        repeat(line.size) {
            add(
                line.toMutableList().apply { removeAt(it) }
            )
        }
    }

    return tries.any { isSafe(it) }
}
