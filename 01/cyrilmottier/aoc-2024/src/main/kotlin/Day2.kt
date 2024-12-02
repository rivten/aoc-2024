import kotlin.math.sign

fun main() {
    val lines = readInput("Day2")
        .map { line ->
            line.split(" ")
                .map { it.toInt() }
        }

    val safeCount = lines
        .count { line ->
            val sign = (line[1] - line[0]).sign
            line.zipWithNext().all { (a, b) -> sign * (b - a) in 1..3 }
        }

    println(safeCount)
}
