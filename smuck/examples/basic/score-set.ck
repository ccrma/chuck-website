//-----------------------------------------------------------------------------
// name: score-set.ck
// desc: this example shows how to build a score from the measure level up 
//
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/), Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------

@import "smuck"

// Create an ezMeasure
ezMeasure measure1;

// Set pitches and rhythms individually using SMucKish 
measure1.pitches("c4 d e f g a b c");
measure1.rhythms("q q e e q q h h");

// Create an ezMeasure with interleaved SMucKish input
ezMeasure measure2("c3|q e g a|e b c g|w");

// Create an ezPart
ezPart part1;

// Add measures to part (sequential)
part1.add([measure1, measure2]);

// Create an ezPart directly from interleaved SMucKish input
ezPart part2("a2x3 bx3 cx2");

// Create a score
ezScore score;

// Add parts to score (parallel)
score.add([part1, part2]);

// Preview the score
ezScorePlayer player(score);
player.preview();

// Let time pass until the score is finished playing
while(player.isPlaying())
{
    second => now;
}