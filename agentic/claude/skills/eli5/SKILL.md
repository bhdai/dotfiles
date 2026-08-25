---
name: eli5
description: Explain a topic like I'm a 5 year old. Use when the user types /eli5 <topic> or asks for a dead-simple picture explainer of how something works.
---

# eli5

Explain like I'm someone who knows nothing about this topic, using a HTML artifact with big
pictures and few words. Dress it like an OpenAI blog post: monochrome, Inter, hairlines, no
chrome, colour, even svg only where it means something.

Topic: $ARGUMENTS

## Draw cast-and-stage, not boxes-and-arrows

A schematic asks to be read. A stage asks to be looked at. Draw the stage.

- **Cast first.** Two or three glyphs, `<symbol>` once, `<use>` forever. Open with a figure
  that introduces them and nothing else. Every later figure recasts the same actors, so the
  reader learns the alphabet once and then reads fluently. Six metaphors for six figures is
  six alphabets.
- **Make the abstraction physical.** A container is not a labelled rectangle; it is a box with
  holes cut in its sides. Data does not flow, it travels and lands. If the mechanism has no
  edges you could touch, keep looking for the metaphor.
- **Colour is the legend.** Four roles, no more. Each one a saturated stroke, a pale tint of
  the same hue, and its own arrowhead marker. Teal means in figure 6 what it meant in figure 2.
  Spend hue on meaning, never on decoration.
- **Weight it like a whiteboard, not a blueprint.** 2–3px strokes, soft corners, shapes washed
  with their own colour. Hairline monochrome reads as engineering; this reads as someone
  explaining.
- **Two voices in the labels.** Sans for the plain-English aside, mono for the technical name.
  Narration sits in the whitespace beside the drawing, stacked in two-word lines, like a note
  in a margin.
- **Stage a scene, not a topology.** Put time in the picture: a clock on the cause, a clock on
  the bang, a dashed trail between them. Before-and-after beats a static map.
- **Caption with an aphorism.** Lowercase, short, a claim and not a description. "count the
  holes, and you know the answer", never "diagram of a container's two type positions".

Page chrome stays OpenAI-blogpost calm. The calm is what lets the figures shout.
