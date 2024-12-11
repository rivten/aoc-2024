import kotlin.math.floor
import kotlin.math.log10
import kotlin.math.pow

fun main() {
    val cache = mutableMapOf<Pair<Long, Int>, Long>()

    fun blink(stone: Long): List<Long> {
        return buildList {
            val digits = floor(log10(stone.toDouble()) + 1).toInt()
            when {
                stone == 0L -> add(1L)
                digits % 2 == 0 -> {
                    val divider = 10.0.pow(digits / 2).toLong()
                    add(stone / divider)
                    add(stone % divider)
                }

                else -> add(stone * 2024)
            }
        }
    }

    fun blink(stone: Long, blinkCount: Int): Long = if (blinkCount == 0) {
        1L
    } else {
        cache[stone to blinkCount] ?: blink(stone)
            .sumOf { blink(it, blinkCount - 1) }.also {
                cache[stone to blinkCount] = it
            }
    }

    val stones = readInput("Day11")[0]
        .split(" ")
        .map { it.toLong() }
        .sumOf { blink(it, 75) }

    println(stones)
}
