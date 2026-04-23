local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	-- Function with docstring: def<Tab>
	s(
		"def",
		fmt(
			[[
def {}({}):
    """{}"""
    {}
]],
			{
				i(1, "func"),
				i(2),
				i(3, "Description"),
				i(4, "pass"),
			}
		)
	),

	-- Main guard: main<Tab>
	s(
		"main",
		fmt(
			[[
if __name__ == "__main__":
    {}
]],
			{ i(1) }
		)
	),

	-- Dataclass: dc<Tab>
	s(
		"dc",
		fmt(
			[[
from dataclasses import dataclass

@dataclass
class {}:
    {}
]],
			{ i(1, "Name"), i(2, "field: type") }
		)
	),

	-- Pytest test: test<Tab>
	s(
		"test",
		fmt(
			[[
def test_{}():
    {}
]],
			{ i(1, "name"), i(2, "assert True") }
		)
	),

	-- Logging basic config: log<Tab>
	s(
		"log",
		fmt(
			[[
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

{}
]],
			{ i(1) }
		)
	),
}
