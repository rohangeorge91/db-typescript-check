
type Dimensions = {
	width: number;
	depth: number;
	height: number;
};

interface IThingamajigHandler {
	numberHandler: (t: Thingamajig) => void;
	stringHandler: (t: Thingamajig) => void;
	objectHandler: (t: Thingamajig) => void;
}

enum ThingamajigColor {
	Red = "RED",
	Blue = "BLUE",
	White = "WHITE"
}

export default class Thingamajig {
	name: string;
	protected dimensions: Dimensions;
	// maybe specifying the type to number | string | object  instead of any.
	private label: any;

	// at a given timestamp calls the function with the Thingamajig
	private giveMeAtTimestamp: number;
	private giveMeAt: ((t: Thingamajig) => void) | null;

	color: ThingamajigColor;

	constructor(
		dimension: Dimensions,
		name: string,
		label: number | string | object,
		giveMeAtTimestamp: number,
		giveMeAt: (t: Thingamajig) => void,
		c: ThingamajigColor
	) {
		this.dimensions = dimension;
		this.name = name;
		this.label = label;
		this.giveMeAtTimestamp = giveMeAtTimestamp;
		this.giveMeAt = giveMeAt;

		// Maybe a check here to ensure the interval is only called 
		const cancel = setInterval(() => {
			if (new Date().valueOf() > this.giveMeAtTimestamp && this.giveMeAt) {
				this.giveMeAt(this);
				// the definition is set to null, may cause an issue/error during execution.
				this.giveMeAt = null;
				clearInterval(cancel);
			}
		}, 1000);

		this.color = c;
	}

	// a Thingamajig is valid if any of its dimensions is less than 100
	validDimensions(): boolean {
		// maybe make the loc a little lesser.
		// const { width, depth, height } = this.dimensions;
		// return width < 100 || depth < 100 || height < 100;
		if (this.dimensions.width < 100) {
			return true;
		} else if (this.dimensions.depth < 100) {
			return true;
		} else if (this.dimensions.height < 100) {
			return true;
		}

		return false;
	}

	// Should accept new dimensions and validate
	updateDim(ds: Dimensions): void {
		this.dimensions = ds;
		// call the function to check the dimension using the variables.
		/* (!this.validDimensions()) {
			throw new Error("Invalid Thingamajig dimensions!");
		}
		*/
		if (!this.validDimensions) throw new Error("Invalid Thingamajig dimensions!");
	}

	// Color comes from an external API and can be a string, validate it is a valid color
	// and then update
	updateCol(co: string): null | never {
		// COMMENT: Object.values(ThingamajigColor).includes(co) instead of the or operator to check the enums is present as any of the menntioned
		if (
			co === ThingamajigColor.Blue ||
			co === ThingamajigColor.Red ||
			co === ThingamajigColor.White
		) {
			this.color = co;
			return null;
		}

		throw new Error(`Invalid Thingamajig color: ${co}!`);
	}

	// There are several services which handle Thingamigs based on their label
	// COMMENT: may specify a return type, also the below code will always give error, is this right?
	handle(h: IThingamajigHandler) {
		if (typeof this.label === "number") {
			h.numberHandler(this);
		} else if (typeof this.label === "object") {
			h.objectHandler(this);
		} else if (typeof this.label === "string") {
			h.stringHandler(this);
		}

		throw new Error("Unexpected label type!");
	}
}
