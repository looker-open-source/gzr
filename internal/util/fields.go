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
	"fmt"
	"strings"
)

// ParseFieldsForHeaders parses a Looker API fields string (which may contain nested fields
// like looks(id,title)) into a flat list of headers (like looks(id), looks(title)).
func ParseFieldsForHeaders(fields string) []string {
	var headers []string
	var current strings.Builder
	var prefix string
	inParens := false

	for _, r := range fields {
		switch r {
		case '(':
			inParens = true
			prefix = current.String()
			current.Reset()
		case ')':
			inParens = false
			subFields := strings.Split(current.String(), ",")
			for _, sf := range subFields {
				headers = append(headers, fmt.Sprintf("%s(%s)", prefix, strings.TrimSpace(sf)))
			}
			current.Reset()
			prefix = ""
		case ',':
			if inParens {
				current.WriteRune(r)
			} else {
				if current.Len() > 0 {
					headers = append(headers, strings.TrimSpace(current.String()))
					current.Reset()
				}
			}
		default:
			current.WriteRune(r)
		}
	}
	if current.Len() > 0 {
		headers = append(headers, strings.TrimSpace(current.String()))
	}
	return headers
}

// HeaderToParts converts a header (possibly nested like permission_set(id))
// into path parts for map traversal (like ["permission_set", "id"]).
func HeaderToParts(h string) []string {
	if idx := strings.Index(h, "("); idx != -1 {
		prefix := h[:idx]
		suffix := h[idx+1 : len(h)-1] // remove trailing ')'
		return []string{prefix, suffix}
	}
	return []string{h}
}
