// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package util

import (
	"encoding/csv"
	"fmt"
	"os"
	"strings"

	"github.com/olekukonko/tablewriter"
	"github.com/olekukonko/tablewriter/renderer"
	"github.com/olekukonko/tablewriter/tw"
)

type Table struct {
	Header []string
	Rows   [][]string
}

func NewTable(header []string) *Table {
	return &Table{
		Header: header,
		Rows:   make([][]string, 0),
	}
}

func (t *Table) Append(row []string) {
	t.Rows = append(t.Rows, row)
}

func (t *Table) Render(plain, isCSV bool) {
	if isCSV {
		w := csv.NewWriter(os.Stdout)
		if !plain && len(t.Header) > 0 {
			_ = w.Write(t.Header)
		}
		for _, row := range t.Rows {
			_ = w.Write(row)
		}
		w.Flush()
		return
	}

	if plain {
		for _, row := range t.Rows {
			fmt.Println(strings.Join(row, "\t"))
		}
		return
	}

	bulkData := make([][]any, len(t.Rows))
	for i, row := range t.Rows {
		bulkRow := make([]any, len(row))
		for j, val := range row {
			bulkRow[j] = val
		}
		bulkData[i] = bulkRow
	}

	rendition := tw.Rendition{
		Symbols: tw.NewSymbols(tw.StyleASCII),
		Borders: tw.Border{Left: tw.On, Right: tw.On, Top: tw.On, Bottom: tw.On},
		Settings: tw.Settings{
			Separators: tw.Separators{
				BetweenColumns: tw.On,
				BetweenRows:    tw.Off,
			},
			Lines: tw.Lines{
				ShowTop:        tw.On,
				ShowBottom:     tw.On,
				ShowHeaderLine: tw.On,
			},
		},
	}

	table := tablewriter.NewTable(os.Stdout,
		tablewriter.WithRenderer(renderer.NewBlueprint(rendition)),
		tablewriter.WithConfig(tablewriter.Config{
			Header: tw.CellConfig{
				Alignment: tw.CellAlignment{Global: tw.AlignLeft},
				Padding:   tw.CellPadding{Global: tw.Padding{Left: " ", Right: " "}},
			},
			Row: tw.CellConfig{
				Alignment: tw.CellAlignment{Global: tw.AlignLeft},
				Padding:   tw.CellPadding{Global: tw.Padding{Left: " ", Right: " "}},
			},
		}),
	)

	if len(t.Header) > 0 {
		headerAny := make([]any, len(t.Header))
		for i, h := range t.Header {
			headerAny[i] = h
		}
		table.Header(headerAny...)
	}

	_ = table.Bulk(bulkData)
	_ = table.Render()
}
