import kotlin.math.abs

fun main() {
    val lines = readInput("Day1")
        .map { line ->
            line.split("   ")
                .map { it.toInt() }
        }

    val left = lines.map { it[0] }.sorted()
    val right = lines.map { it[1] }.sorted()

    val result = left
        .zip(right)
        .sumOf { (l, r) ->
            abs(r - l)
        }

    println(result)
}
