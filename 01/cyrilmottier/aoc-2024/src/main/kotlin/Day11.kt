import kotlin.math.floor
import kotlin.math.log10
import kotlin.math.pow

fun main() {
    val cache = mutableMapOf<Pair<Long, Int>, List<Long>>()

    fun blink(stone: Long, blinkCount: Int): List<Long> {
        val blinkCache = cache[stone to blinkCount]
        if (blinkCache != null) {
            return blinkCache
        }

        val digits = floor(log10(stone.toDouble()) + 1).toInt()

        val result = when {
            stone == 0L -> listOf(1L)
            digits % 2 == 0 -> {
                val divider = 10.0.pow(digits / 2).toLong()
                listOf(stone / divider, stone % divider)
            }

            else -> listOf(stone * 2024)
        }

        cache[stone to blinkCount] = result

        return result
    }

    fun compute(stones: List<Long>, blinkCount: Int): List<Long> {
        if (blinkCount == 0) {
            return stones
        }
        val newStones = stones.flatMap { blink(it, blinkCount) }
        return compute(newStones, blinkCount - 1)
    }

    val stones = readInput("Day11")[0]
        .split(" ")
        .map { it.toLong() }

    println(compute(stones, 25).size)
}
