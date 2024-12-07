import kotlin.math.floor
import kotlin.math.log10
import kotlin.math.pow

fun main() {
    val matches = readInput("Day7")
        .map { it.split(": ") }
        .map { (right, left) ->
            right.toLong() to left.split(" ").map { it.toLong() }
        }
        .filter { (expected, operands) ->
            val operationCount = operands.size - 1
            val possibilities = 3.0.pow(operationCount).toInt()
            (0..<possibilities).any { operations ->
                expected == operands.reduceIndexed { index, acc, operand ->
                    val operation = (operations / (3.0.pow(index - 1).toInt())) % 3
                    when (operation) {
                        0 -> acc + operand
                        1 -> acc * operand
                        2 -> acc * 10.0.pow(floor(log10(operand.toDouble()) + 1)).toInt() + operand
                        else -> error("")
                    }
                }
            }
        }
        .sumOf { (expected, _) -> expected }

    println(matches)
}
