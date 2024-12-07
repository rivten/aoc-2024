import kotlin.math.pow

fun main() {
    val matches = readInput("Day7")
        .map { it.split(": ") }
        .map { (right, left) ->
            right.toLong() to left.split(" ").map { it.toLong() }
        }
        .filter { (expected, operands) ->
            val operationCount = operands.size - 1
            val possibilities = 2.0.pow(operationCount).toInt()
            (0..<possibilities).any { operations ->
                expected == operands.reduceIndexed { index, acc, operand ->
                    val operation = (operations shr (index - 1)) and 1
                    if (operation == 1) {
                        acc + operand
                    } else {
                        acc * operand
                    }
                }

            }
        }
        .sumOf { (expected, _) -> expected }

    println(matches)
}
