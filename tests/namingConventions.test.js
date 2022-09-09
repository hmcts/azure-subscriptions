#!/usr/bin/env node

const fs = require("fs");

describe("Naming conventions", () => {
  const variables = JSON.parse(
    fs.readFileSync("/tmp/variables.json", { encoding: "utf-8" })
  );

  // noinspection JSMismatchedCollectionQueryUpdate remove this noinspection if any exclusions are added
  const globalExclusions = [];

  const managementGroupSubscriptions = Object.keys(variables)
    .filter((key) => key.includes("_subscriptions"))
    .reduce((obj, key) => {
      if (Object.keys(variables[key][0]).length > 0) {
        return Object.assign(obj, variables[key]);
      }
      return obj;
    }, [])
    .flatMap((obj) => Object.keys(obj));

  it("starts with a valid department", () => {
    // noinspection JSMismatchedCollectionQueryUpdate remove this noinspection if any exclusions are added
    const localExclusions = [];

    managementGroupSubscriptions
      .filter(
        (sub) =>
          !globalExclusions.includes(sub) && !localExclusions.includes(sub)
      )
      .forEach((subscription) => {
        expect(subscription).toMatch(/^(HMCTS|DTS|DCD)-/);
      });
  });

  it("contains a service name", () => {
    // noinspection JSMismatchedCollectionQueryUpdate remove this noinspection if any exclusions are added
    const localExclusions = [];

    managementGroupSubscriptions
      .filter(
        (sub) =>
          !globalExclusions.includes(sub) && !localExclusions.includes(sub)
      )
      .forEach((subscription) => {
        expect(subscription).toMatch(/^(.+)-(.+)-/);
      });
  });

  it("ends with a valid environment", () => {
    // noinspection JSMismatchedCollectionQueryUpdate remove this noinspection if any exclusions are added
    const localExclusions = [];

    managementGroupSubscriptions
      .filter(
        (sub) =>
          !globalExclusions.includes(sub) && !localExclusions.includes(sub)
      )
      .forEach((subscription) => {
        expect(subscription).toMatch(
          /^(.+)-(.+)-(SBOX|DEV|TEST|ITHC|DEMO|STG|PROD)/
        );
      });
  });
});
