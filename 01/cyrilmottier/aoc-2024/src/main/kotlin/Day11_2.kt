import kotlin.math.floor
import kotlin.math.log10
import kotlin.math.pow

fun main() {
    val cache = mutableMapOf<Int, MutableMap<Long, Long>>()
    val listCache = mutableMapOf<Long, List<Long>>()

    fun apply(stone: Long): List<Long> {
        val digits = floor(log10(stone.toDouble()) + 1).toInt()
        return when {
            stone == 0L -> listOf(1L)
            digits % 2 == 0 -> {
                val divider = 10.0.pow(digits / 2).toLong()
                listOf(stone / divider, stone % divider)
            }

            else -> listOf(stone * 2024)
        }
    }

    fun rule(stone: Long): List<Long> {
        val c = listCache[stone]
        if (c != null) return c
        return apply(stone).also {
            listCache[stone] = it
        }
    }

    fun compute(stone: Long, blinkCount: Int): Long {
        var blinkCache = cache[blinkCount]
        if (blinkCache == null) {
            blinkCache = mutableMapOf<Long, Long>().also {
                cache[blinkCount] = it
            }
        }
        val stoneCountCache = blinkCache[stone]
        if (stoneCountCache != null) {
            return stoneCountCache
        }

        if (blinkCount == 0) return 1L

        return rule(stone).sumOf { compute(it, blinkCount - 1) }.also {
            blinkCache[stone] = it
        }
    }

    val stones = readInput("Day11")[0]
        .split(" ")
        .map { it.toLong() }
        .sumOf { compute(it, 75) }

    println(stones)
}
