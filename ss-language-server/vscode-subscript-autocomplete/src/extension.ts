/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/

import * as vscode from 'vscode';
const sourceType = "subscript";


function block(name: string): {name: string, insert: string} {
	return {name: name, insert: `${name}` + '{${1}}'}
}

const globalTags = [
	{name: 'include', insert: 'include[src="${1}"]'},
	{name: 'include[baseline="h2"]', insert: 'include[src="${1}", baseline="h2"]'},
	{name: 'include[baseline="h3"]', insert: 'include[src="${1}", baseline="h3"]'},
	{name: 'include[baseline="h4"]', insert: 'include[src="${1}", baseline="h4"]'},
	block('h1'),
	block('h2'),
	block('h3'),
	block('h4'),
	block('h5'),
	block('h6'),
	block('layout[col=1]'),
	block('layout[col=2]'),
	block('layout[col=3]'),
	block('layout[col=4]'),
	block('note'),
	block('math'),
	block('equation'),
	block('address'),
	block('article'),
	block('aside'),
	block('footer'),
	block('header'),
	block('section'),
	block('blockquote'),
	block('dd'),
	block('dl'),
	block('dt'),
	block('figcaption'),
	block('figure'),
	block('hr'),
	block('li'),
	block('ol'),
	block('p'),
	block('pre'),
	block('ul'),
	block('a'),
	block('abbr'),
	block('b'),
	block('bdi'),
	block('bdo'),
	block('br'),
	block('cite'),
	block('code'),
	block('data'),
	block('dfn'),
	block('em'),
	block('i'),
	block('kbd'),
	block('mark'),
	block('q'),
	block('s'),
	block('samp'),
	block('small'),
	block('span'),
	block('strong'),
	block('sub'),
	block('sup'),
	block('time'),
	block('u'),
	block('var'),
	block('wbr'),
	block('audio'),
	block('img'),
	block('map'),
	block('area'),
	block('object'),
	block('picture'),
	block('source'),
	block('del'),
	block('ins'),
	block('caption'),
	block('table'),
	block('tbody'),
	block('td'),
	block('tfoot'),
	block('th'),
	block('tr'),
	block('thead'),
	block('details'),
	block('summary'),
];


export function activate(context: vscode.ExtensionContext) {

	const provider1 = vscode.languages.registerCompletionItemProvider(
		sourceType,
		{
			provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token: vscode.CancellationToken, context: vscode.CompletionContext) {
	
				// a simple completion item which inserts `Hello World!`
				// const simpleCompletion = new vscode.CompletionItem('hello');
				let xs: Array<vscode.CompletionItem> = []
				for (const entry of globalTags) {
					const completion = new vscode.CompletionItem(entry.name, vscode.CompletionItemKind.Function);
					completion.insertText = new vscode.SnippetString(entry.insert);
					xs.push(completion);
					// const docs : any = new vscode.MarkdownString("H1 Heading Tag");
					// completion.documentation = docs;
				}
				
				// return all completion items as array
				return xs;
			}
		},
		'\\'
	);

	// context.subscriptions.push(provider1, provider2);
	context.subscriptions.push(provider1);
}
