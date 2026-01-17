Golay Code Verilog Implementation
=================================

An implementation of an extended binary Golay encoder and sophisticated
low-resource decoder in Verilog. Code in question: [24,12,8]. Corresponding
group: G12. This code maps 12 input bits to 24 output bits, and is able to
correct up to three errors, and detect four errors.

The encoder and decoder have been formally verified, you can find the
self-testing testbench in this repository. Also this lead to the discovery of
an error in the primary paper this implementation was based on. We corrected
said error in this implementation.

Resource usage is very low, and logic depth is fairly low:

```
+-----------+--------+------------+------------+---------+------+-----+--------+--------+------+------------+
|  Instance | Module | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | URAM | DSP Blocks |
+-----------+--------+------------+------------+---------+------+-----+--------+--------+------+------------+
| golay_enc |  (top) |         18 |         18 |       0 |    0 |   0 |      0 |      0 |    0 |          0 |
+-----------+--------+------------+------------+---------+------+-----+--------+--------+------+------------+
+-----------------+-------------+----+----+
| End Point Clock | Requirement |  0 |  2 |
+-----------------+-------------+----+----+
| (none)          | 0.000ns     | 12 | 12 |
+-----------------+-------------+----+----+
```

```
+-----------+--------+------------+------------+---------+------+-----+--------+--------+------+------------+
|  Instance | Module | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | URAM | DSP Blocks |
+-----------+--------+------------+------------+---------+------+-----+--------+--------+------+------------+
| golay_dec |  (top) |        173 |        173 |       0 |    0 |   0 |      0 |      0 |    0 |          0 |
+-----------+--------+------------+------------+---------+------+-----+--------+--------+------+------------+
+-----------------+-------------+----+
| End Point Clock | Requirement |  8 |
+-----------------+-------------+----+
| (none)          | 0.000ns     | 37 |
+-----------------+-------------+----+

```

If you integrate this code into a larger design, you will probably need to add
some input and output register slices to the decoder, in order to improve its
timing! Currently its OOC delay is 1.812 ns for US+ speed grade -3, so that
should only be necessary in case of a high-frequency design. There is also the
option to pipeline the decoder and spread its logic over several pipeline
stages, I just haven't seen the need for it really, but feel free to add an
implementation that can be turned on via a generic and commit to this
repository! Just be careful and refactor the code somewhat nice, such that
there is no code deduplication.

Codes like this are used for space communication, so have fun!
